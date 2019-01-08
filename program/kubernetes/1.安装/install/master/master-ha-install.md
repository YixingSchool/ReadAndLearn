

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [前言](#前言)
* [TLS 证书文件](#tls-证书文件)
	* [方式一](#方式一)
	* [方式二](#方式二)
* [配置和启动 Kube-Apiserver](#配置和启动-kube-apiserver)
* [配置和启动 Kube-Controller-Manager](#配置和启动-kube-controller-manager)
* [启动 Kube-Scheduler](#启动-kube-scheduler)
* [验证 Master 节点功能](#验证-master-节点功能)
* [后记](#后记)

<!-- /code_chunk_output -->

-----

* [Kubernetes高可用Master节点安装_Kubernetes中文社区 ](https://www.kubernetes.org.cn/1865.html)
* [opsnull/follow-me-install-kubernetes-cluster: 和我一步步部署 kubernetes 集群 ](https://github.com/opsnull/follow-me-install-kubernetes-cluster)
* [Kubernetes - Jimmy Song ](http://rootsongjc.github.io/tags/kubernetes/)
* [rootsongjc/kubernetes-handbook: Kubernetes中文指南/实践手册 ](https://github.com/rootsongjc/kubernetes-handbook)
* [1. 前言 · kubernetes-handbook ](https://rootsongjc.gitbooks.io/kubernetes-handbook/content/)

-----


# 前言

这是[和我一步步部署kubernetes集群](https://github.com/rootsongjc/follow-me-install-kubernetes-cluster)项目((fork自[opsnull](https://github.com/opsnull)))中的一篇文章，下文是结合我之前部署kubernetes的过程产生的kuberentes环境，部署master节点的kube-apiserver、kube-controller-manager和kube-scheduler的过程。

高可用Kubernetes Master节点安装

kubernetes master 节点包含的组件：
* kube-apiserver
* kube-scheduler
* kube-controller-manager

目前这三个组件需要部署在同一台机器上。
* `kube-scheduler`、`kube-controller-manager` 和 `kube-apiserver` 三者的功能紧密相关；
* 同时只能有一个 `kube-scheduler`、`kube-controller-manager` 进程处于工作状态，如果运行多个，则需要通过选举产生一个 leader；

本文档记录部署一个三个节点的高可用 kubernetes master 集群步骤。（后续创建一个 load balancer 来代理访问 kube-apiserver 的请求）

# TLS 证书文件

pem和token.csv证书文件我们在TLS证书和秘钥这一步中已经创建过了。我们再检查一下。
$ ls /etc/kubernetes/ssl
admin-key.pem  admin.pem  ca-key.pem  ca.pem  kube-proxy-key.pem  kube-proxy.pem  kubernetes-key.pem  kubernetes.pem

下载最新版本的二进制文件

有两种下载方式

## 方式一

从 github release 页面 下载发布版 tarball，解压后再执行下载脚本
```sh
$ wget https://github.com/kubernetes/kubernetes/releases/download/v1.6.0/kubernetes.tar.gz
$ tar -xzvf kubernetes.tar.gz
...
$ cd kubernetes
$ ./cluster/get-kube-binaries.sh
...
```

## 方式二

> tarball是linux下最方便的打包工具

从 CHANGELOG页面 下载 client 或 server tarball 文件

server 的 tarball kubernetes-server-linux-amd64.tar.gz 已经包含了 client(kubectl) 二进制文件，所以不用单独下载kubernetes-client-linux-amd64.tar.gz文件；
```sh
$ # wget https://dl.k8s.io/v1.6.0/kubernetes-client-linux-amd64.tar.gz
$ wget https://dl.k8s.io/v1.6.0/kubernetes-server-linux-amd64.tar.gz
$ tar -xzvf kubernetes-server-linux-amd64.tar.gz
...
$ cd kubernetes
$ tar -xzvf  kubernetes-src.tar.gz
```

将二进制文件拷贝到指定路径
```sh
$ cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet} /root/local/bin/
```

# 配置和启动 Kube-Apiserver

创建 `kube-apiserver`的`service`配置文件

serivce配置文件`/usr/lib/systemd/system/kube-apiserver.service`内容：
```conf
[Unit]
Description=Kubernetes API Service
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
After=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
ExecStart=/usr/bin/kube-apiserver \
	    $KUBE_LOGTOSTDERR \
	    $KUBE_LOG_LEVEL \
	    $KUBE_ETCD_SERVERS \
	    $KUBE_API_ADDRESS \
	    $KUBE_API_PORT \
	    $KUBELET_PORT \
	    $KUBE_ALLOW_PRIV \
	    $KUBE_SERVICE_ADDRESSES \
	    $KUBE_ADMISSION_CONTROL \
	    $KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

/etc/kubernetes/config文件的内容为：
```conf
###
# kubernetes system config
#
# The following values are used to configure various aspects of all
# kubernetes services, including
#
#   kube-apiserver.service
#   kube-controller-manager.service
#   kube-scheduler.service
#   kubelet.service
#   kube-proxy.service
# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=true"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=true"

# How the controller-manager, scheduler, and proxy find the apiserver
#KUBE_MASTER="--master=http://sz-pg-oam-docker-test-001.tendcloud.com:8080"
KUBE_MASTER="--master=http://172.20.0.113:8080"
```

该配置文件同时被kube-apiserver、kube-controller-manager、kube-scheduler、kubelet、kube-proxy使用。

apiserver配置文件/etc/kubernetes/apiserver内容为：
```sh
###
## kubernetes system config
##
## The following values are used to configure the kube-apiserver
##
#
## The address on the local server to listen to.
#KUBE_API_ADDRESS="--insecure-bind-address=sz-pg-oam-docker-test-001.tendcloud.com"
KUBE_API_ADDRESS="--advertise-address=172.20.0.113 --bind-address=172.20.0.113 --insecure-bind-address=172.20.0.113"
#
## The port on the local server to listen on.
#KUBE_API_PORT="--port=8080"
#
## Port minions listen on
#KUBELET_PORT="--kubelet-port=10250"
#
## Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS="--etcd-servers=https://172.20.0.113:2379,172.20.0.114:2379,172.20.0.115:2379"
#
## Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
#
## default admission control policies
KUBE_ADMISSION_CONTROL="--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota"
#
## Add your own!
KUBE_API_ARGS="--authorization-mode=RBAC --runtime-config=rbac.authorization.k8s.io/v1beta1 --kubelet-https=true --experimental-bootstrap-token-auth --token-auth-file=/etc/kubernetes/token.csv --service-node-port-range=30000-32767 --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --client-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem --enable-swagger-ui=true --apiserver-count=3 --audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/lib/audit.log --event-ttl=1h"
```

•--authorization-mode=RBAC 指定在安全端口使用 RBAC 授权模式，拒绝未通过授权的请求；
•kube-scheduler、kube-controller-manager 一般和 kube-apiserver 部署在同一台机器上，它们使用非安全端口和 kube-apiserver通信;
•kubelet、kube-proxy、kubectl 部署在其它 Node 节点上，如果通过安全端口访问 kube-apiserver，则必须先通过 TLS 证书认证，再通过 RBAC 授权；
•kube-proxy、kubectl 通过在使用的证书里指定相关的 User、Group 来达到通过 RBAC 授权的目的；
•如果使用了 kubelet TLS Boostrap 机制，则不能再指定 --kubelet-certificate-authority、--kubelet-client-certificate 和 --kubelet-client-key 选项，否则后续 kube-apiserver 校验 kubelet 证书时出现 ”x509: certificate signed by unknown authority“ 错误；
•--admission-control 值必须包含 ServiceAccount；
•--bind-address 不能为 127.0.0.1；
•runtime-config配置为rbac.authorization.k8s.io/v1beta1，表示运行时的apiVersion；
•--service-cluster-ip-range 指定 Service Cluster IP 地址段，该地址段不能路由可达；
•缺省情况下 kubernetes 对象保存在 etcd /registry 路径下，可以通过 --etcd-prefix参数进行调整；

完整 unit 见 kube-apiserver.service

启动kube-apiserver
```sh
$ systemctl daemon-reload
$ systemctl enable kube-apiserver
$ systemctl start kube-apiserver
$ systemctl status kube-apiserver
```

# 配置和启动 Kube-Controller-Manager

创建 kube-controller-manager的serivce配置文件

文件路径/usr/lib/systemd/system/kube-controller-manager.service
```conf
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/controller-manager
ExecStart=/usr/bin/kube-controller-manager \
	    $KUBE_LOGTOSTDERR \
	    $KUBE_LOG_LEVEL \
	    $KUBE_MASTER \
	    $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

配置文件/etc/kubernetes/controller-manager。
```conf
###
# The following values are used to configure the kubernetes controller-manager

# defaults from config and apiserver should be adequate

# Add your own!
KUBE_CONTROLLER_MANAGER_ARGS="--address=127.0.0.1 --service-cluster-ip-range=10.254.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem --root-ca-file=/etc/kubernetes/ssl/ca.pem --leader-elect=true"
```

•--service-cluster-ip-range 参数指定 Cluster 中 Service 的CIDR范围，该网络在各 Node 间必须路由不可达，必须和 kube-apiserver 中的参数一致；
•--cluster-signing-* 指定的证书和私钥文件用来签名为 TLS BootStrap 创建的证书和私钥；
•--root-ca-file 用来对 kube-apiserver 证书进行校验，指定该参数后，才会在Pod 容器的 ServiceAccount 中放置该 CA 证书文件；
•--address 值必须为 127.0.0.1，因为当前 kube-apiserver 期望 scheduler 和 controller-manager 在同一台机器，否则：
  $ kubectl get componentstatuses
  NAME                 STATUS      MESSAGE                                                                                        ERROR
  scheduler            Unhealthy   Get http://127.0.0.1:10251/healthz: dial tcp 127.0.0.1:10251: getsockopt: connection refused   
  controller-manager   Healthy     ok                                                                                             
  etcd-2               Unhealthy   Get http://172.20.0.113:2379/health: malformed HTTP response "\x15\x03\x01\x00\x02\x02"        
  etcd-0               Healthy     {"health": "true"}                                                                             
  etcd-1               Healthy     {"health": "true"}  

参考：https://github.com/kubernetes-incubator/bootkube/issues/64

完整 unit 见 kube-controller-manager.service

启动 Kube-Controller-Manager
```sh
$ systemctl daemon-reload
$ systemctl enable kube-controller-manager
$ systemctl start kube-controller-manager
```
配置和启动 Kube-Scheduler

创建 kube-scheduler的serivce配置文件

文件路径/usr/lib/systemd/system/kube-scheduler.serivce。
```conf
[Unit]
Description=Kubernetes Scheduler Plugin
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/scheduler
ExecStart=/usr/bin/kube-scheduler \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBE_MASTER \
            $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

配置文件/etc/kubernetes/scheduler。
```conf
###
# kubernetes scheduler config

# default config should be adequate

# Add your own!
KUBE_SCHEDULER_ARGS="--leader-elect=true --address=127.0.0.1"
```

* --address 值必须为 127.0.0.1，因为当前 kube-apiserver 期望 scheduler 和 controller-manager 在同一台机器；

完整 unit 见 kube-scheduler.service

# 启动 Kube-Scheduler
```sh
$ systemctl daemon-reload
$ systemctl enable kube-scheduler
$ systemctl start kube-scheduler
```

# 验证 Master 节点功能
```sh
$ kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok                   
controller-manager   Healthy   ok                   
etcd-0               Healthy   {"health": "true"}   
etcd-1               Healthy   {"health": "true"}   
etcd-2               Healthy   {"health": "true"}   
```

# 后记

* [Kubernetes Master High Availability 高级实践 - Caicloud - SegmentFault ](https://segmentfault.com/a/1190000005832319)

当时在配置过程中遇到了问题[TLS认证相关的问题](https://github.com/opsnull/follow-me-install-kubernetes-cluster/issues/4)，其实就是因为配置apiserver时候etcd的协议写成了http导致的，应该是用https。

[Opsnull](https://github.com/opsnull/follow-me-install-kubernetes-cluster)写的kubernetes高可用master集群部署过程中似乎并没有包括高可用的配置，才云科技的唐继元分享过[Kubernetes Master High Availability 高级实践](https://segmentfault.com/a/1190000005832319)。

究竟如何实现kubernetes master的高可用还需要继续探索。
