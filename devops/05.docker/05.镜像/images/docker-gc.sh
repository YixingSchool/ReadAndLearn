#!/bin/bash

# Copyright (c) 2014 Spotify AB.
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# This script attempts to garbage collect docker containers and images.
# Containers that exited more than an hour ago are removed.
# Images that have existed more than an hour and are not in use by any
# containers are removed.

# Note: Although docker normally prevents removal of images that are in use by
#       containers, we take extra care to not remove any image tags (e.g.
#       ubuntu:14.04, busybox, etc) that are used by containers. A naive
#       "docker rmi `docker images -q`" will leave images stripped of all tags,
#       forcing users to re-pull the repositories even though the images
#       themselves are still on disk.

# Note: State is stored in $STATE_DIR, defaulting to /var/lib/docker-gc

# The script can send log messages to syslog regarding which images and
# containers were removed. To enable logging to syslog, set LOG_TO_SYSLOG=1.
# When disabled, this script will instead log to standard out. When syslog is
# enabled, the syslog facility and logger can be configured with
# $SYSLOG_FACILITY and $SYSLOG_LEVEL respectively.

set -o nounset
set -o errexit

GRACE_PERIOD_SECONDS=${GRACE_PERIOD_SECONDS:=3600}
MINIMUM_IMAGES_TO_SAVE=${MINIMUM_IMAGES_TO_SAVE:=0}
STATE_DIR=${STATE_DIR:=/var/lib/docker-gc}
FORCE_CONTAINER_REMOVAL=${FORCE_CONTAINER_REMOVAL:=0}
FORCE_IMAGE_REMOVAL=${FORCE_IMAGE_REMOVAL:=0}
DOCKER=${DOCKER:=docker}
PID_DIR=${PID_DIR:=/var/run}
LOG_TO_SYSLOG=${LOG_TO_SYSLOG:=0}
SYSLOG_FACILITY=${SYSLOG_FACILITY:=user}
SYSLOG_LEVEL=${SYSLOG_LEVEL:=info}
SYSLOG_TAG=${SYSLOG_TAG:=docker-gc}
DRY_RUN=${DRY_RUN:=0}
EXCLUDE_DEAD=${EXCLUDE_DEAD:=0}
PIDFILE=$PID_DIR/dockergc

exec 3>>$PIDFILE
if ! flock -x -n 3; then
  echo "[$(date)] : docker-gc : Process is already running"
  exit 1
fi

trap "rm -f -- '$PIDFILE'" EXIT

echo $$ > $PIDFILE

EXCLUDE_FROM_GC=${EXCLUDE_FROM_GC:=/etc/docker-gc-exclude}
if [ ! -f "$EXCLUDE_FROM_GC" ]
then
  EXCLUDE_FROM_GC=/dev/null
fi

EXCLUDE_CONTAINERS_FROM_GC=${EXCLUDE_CONTAINERS_FROM_GC:=/etc/docker-gc-exclude-containers}
if [ ! -f "$EXCLUDE_CONTAINERS_FROM_GC" ]
then
  EXCLUDE_CONTAINERS_FROM_GC=/dev/null
fi

EXCLUDE_IDS_FILE="exclude_ids"
EXCLUDE_CONTAINER_IDS_FILE="exclude_container_ids"

function date_parse {
  if date --utc >/dev/null 2>&1; then
    # GNU/date
    echo $(date -u --date "${1}" "+%s")
  else
    # BSD/date
    echo $(date -j -u -f "%F %T" "${1}" "+%s")
  fi
}

# Elapsed time since a docker timestamp, in seconds
function elapsed_time() {
    # Docker 1.5.0 datetime format is 2015-07-03T02:39:00.390284991
    # Docker 1.7.0 datetime format is 2015-07-03 02:39:00.390284991 +0000 UTC
    utcnow=$(date -u "+%s")
    replace_q="${1#\"}"
    without_ms="${replace_q:0:19}"
    replace_t="${without_ms/T/ }"
    epoch=$(date_parse "${replace_t}")
    echo $(($utcnow - $epoch))
}

function compute_exclude_ids() {
    # Find images that match patterns in the EXCLUDE_FROM_GC file and put their
    # id prefixes into $EXCLUDE_IDS_FILE, prefixed with ^

    PROCESSED_EXCLUDES="processed_excludes.tmp"
    # Take each line and put a space at the beginning and end, so when we
    # grep for them below, it will effectively be: "match either repo:tag
    # or imageid".  Also delete blank lines or lines that only contain
    # whitespace
    sed 's/^\(.*\)$/ \1 /' $EXCLUDE_FROM_GC | sed '/^ *$/d' > $PROCESSED_EXCLUDES
    # The following looks a bit of a mess, but here's what it does:
    # 1. Get images
    # 2. Skip header line
    # 3. Turn columnar display of 'REPO TAG IMAGEID ....' to 'REPO:TAG IMAGEID'
    # 4. find lines that contain things mentioned in PROCESSED_EXCLUDES
    # 5. Grab the image id from the line
    # 6. Prepend ^ to the beginning of each line

    # What this does is make grep patterns to match image ids mentioned by
    # either repo:tag or image id for later greppage
    $DOCKER images \
        | tail -n+2 \
        | sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' \
        | grep -f $PROCESSED_EXCLUDES 2>/dev/null \
        | cut -d' ' -f3 \
        | sed 's/^/^(sha256:)?/' > $EXCLUDE_IDS_FILE
}

function compute_exclude_container_ids() {
    # Find containers matching to patterns listed in EXCLUDE_CONTAINERS_FROM_GC file
    # Implode their values with a \| separator on a single line
    PROCESSED_EXCLUDES=`cat $EXCLUDE_CONTAINERS_FROM_GC \
        | xargs \
        | sed -e 's/ /\|/g'`
    # The empty string would match everything
    if [ "$PROCESSED_EXCLUDES" = "" ]; then
        touch $EXCLUDE_CONTAINER_IDS_FILE
        return
    fi
    # Find all docker images
    # Filter out with matching names
    # and put them to $EXCLUDE_CONTAINER_IDS_FILE
    $DOCKER ps -a \
        | grep -E "$PROCESSED_EXCLUDES" \
        | awk '{ print $1 }' \
        | tr -s " " "\012" \
        | sort -u > $EXCLUDE_CONTAINER_IDS_FILE
}

function log() {
    msg=$1
    if [[ $LOG_TO_SYSLOG -gt 0 ]]; then
        logger -i -t "$SYSLOG_TAG" -p "$SYSLOG_FACILITY.$SYSLOG_LEVEL" "$msg"
    else
        echo "[$(date +'%Y-%m-%dT%H:%M:%S')] [INFO] : $msg"
    fi
}

function container_log() {
    prefix=$1
    filename=$2

    while IFS='' read -r containerid
    do
        log "$prefix $containerid $(${DOCKER} inspect -f {{.Name}} $containerid)"
    done < "$filename"
}

function image_log() {
    prefix=$1
    filename=$2

    while IFS='' read -r imageid
    do
        log "$prefix $imageid $(${DOCKER} inspect -f {{.RepoTags}} $imageid)"
    done < "$filename"
}

# Change into the state directory (and create it if it doesn't exist)
if [ ! -d "$STATE_DIR" ]
then
  mkdir -p $STATE_DIR
fi
cd "$STATE_DIR"

# Verify that docker is reachable
$DOCKER version 1>/dev/null

# List all currently existing containers
$DOCKER ps -a -q --no-trunc | sort | uniq > containers.all

# List running containers
$DOCKER ps -q --no-trunc | sort | uniq > containers.running
container_log "Container running" containers.running

# compute ids of container images to exclude from GC
compute_exclude_ids

# compute ids of containers to exclude from GC
compute_exclude_container_ids

# List containers that are not running
comm -23 containers.all containers.running > containers.exited

if [[ $EXCLUDE_DEAD -gt 0 ]]; then
    echo "Excluding dead containers"
    # List dead containers
    $DOCKER ps -q -a -f status=dead | sort | uniq > containers.dead
    comm -23 containers.exited containers.dead > containers.exited.tmp
    cat containers.exited.tmp > containers.exited
fi

container_log "Container not running" containers.exited

# Find exited containers that finished at least GRACE_PERIOD_SECONDS ago
> containers.reap.tmp
cat containers.exited | while read line
do
    EXITED=$(${DOCKER} inspect -f "{{json .State.FinishedAt}}" ${line})
    ELAPSED=$(elapsed_time $EXITED)
    if [[ $ELAPSED -gt $GRACE_PERIOD_SECONDS ]]; then
        echo $line >> containers.reap.tmp
    fi
done

# List containers that we will remove and exclude ids.
cat containers.reap.tmp | sort | uniq | grep -v -f $EXCLUDE_CONTAINER_IDS_FILE > containers.reap || true

# List containers that we will keep.
comm -23 containers.all containers.reap > containers.keep

# List images used by containers that we keep.
cat containers.keep |
xargs -n 1 $DOCKER inspect -f '{{.Image}}' 2>/dev/null |
sort | uniq > images.used

# List images to reap; images that existed last run and are not in use.
echo -n "" > images.all
$DOCKER images | while read line
do
    awk '{print $1};'
done | sort | uniq | while read line
do
  $DOCKER images --no-trunc --format "{{.ID}} {{.CreatedAt}}" $line \
    | sort -k 2 -r \
    | tail -n +$((MINIMUM_IMAGES_TO_SAVE+1)) \
    | cut -f 1 -d " " \
    | uniq >> images.all
done

# Add dangling images to list.
$DOCKER images --no-trunc --format "{{.ID}}" --filter dangling=true >> images.all

# Find images that are created at least GRACE_PERIOD_SECONDS ago
> images.reap.tmp
cat images.all | sort | uniq | while read line
do
    CREATED=$(${DOCKER} inspect -f "{{.Created}}" ${line})
    ELAPSED=$(elapsed_time $CREATED)
    if [[ $ELAPSED -gt $GRACE_PERIOD_SECONDS ]]; then
        echo $line >> images.reap.tmp
    fi
done
comm -23 images.reap.tmp images.used | grep -E -v -f $EXCLUDE_IDS_FILE > images.reap || true

# Use -f flag on docker rm command; forces removal of images that are in Dead
# status or give errors when removing.
FORCE_CONTAINER_FLAG=""
if [[ $FORCE_CONTAINER_REMOVAL -gt 0 ]]; then
    FORCE_CONTAINER_FLAG="-f"
fi
# Reap containers.
if [[ $DRY_RUN -gt 0 ]]; then
    container_log "The following container would have been removed" containers.reap
else
    container_log "Removing containers" containers.reap
    xargs -n 1 $DOCKER rm $FORCE_CONTAINER_FLAG --volumes=true < containers.reap &>/dev/null || true
fi

# Use -f flag on docker rmi command; forces removal of images that have multiple tags
FORCE_IMAGE_FLAG=""
if [[ $FORCE_IMAGE_REMOVAL -gt 0 ]]; then
    FORCE_IMAGE_FLAG="-f"
fi

# Reap images.
if [[ $DRY_RUN -gt 0 ]]; then
    image_log "The following image would have been removed" images.reap
else
    image_log "Removing image" images.reap
    xargs -n 1 $DOCKER rmi $FORCE_IMAGE_FLAG < images.reap &>/dev/null || true
fi