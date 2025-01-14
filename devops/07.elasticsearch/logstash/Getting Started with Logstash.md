

# Getting Started with Logstash | Logstash Reference [5.1] | Elastic 
https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html


This section guides you through the process of installing Logstash and verifying that everything is running properly. After learning how to stash your first event, you go on to create a more advanced pipeline that takes Apache web logs as input, parses the logs, and writes the parsed data to an Elasticsearch cluster. Then you learn how to stitch together multiple input and output plugins to unify data from a variety of disparate sources.
This section includes the following topics:
•	Installing Logstash
•	Stashing Your First Event
•	Parsing Logs with Logstash
•	Stitching Together Multiple Input and Output Plugins



Installing Logstash | Logstash Reference [5.1] | Elastic 
https://www.elastic.co/guide/en/logstash/current/installing-logstash.html



  Stashing Your First Event  »
Installing Logstashedit
 
Logstash requires Java 8. Java 9 is not supported. Use the official Oracle distribution or an open-source distribution such as OpenJDK.
To check your Java version, run the following command:
java -version
On systems with Java installed, this command produces output similar to the following:
java version "1.8.0_65"
Java(TM) SE Runtime Environment (build 1.8.0_65-b17)
Java HotSpot(TM) 64-Bit Server VM (build 25.65-b01, mixed mode)
Installing from a Downloaded Binaryedit
Download the Logstash installation file that matches your host environment. Unpack the file. Do not install Logstash into a directory path that contains colon (:) characters.
On supported Linux operating systems, you can use a package manager to install Logstash.
Installing from Package Repositoriesedit
We also have repositories available for APT and YUM based distributions. Note that we only provide binary packages, but no source packages, as the packages are created as part of the Logstash build.
We have split the Logstash package repositories by version into separate urls to avoid accidental upgrades across major versions. For all 5.x.y releases use 5.x as version number.
We use the PGP key D88E42B4, Elastic’s Signing Key, with fingerprint
4609 5ACC 8548 582C 1A26 99A9 D27D 666C D88E 42B4
to sign all our packages. It is available from https://pgp.mit.edu.
APTedit
Download and install the Public Signing Key:
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
You may need to install the apt-transport-https package on Debian before proceeding:
sudo apt-get install apt-transport-https
Save the repository definition to /etc/apt/sources.list.d/elastic-5.x.list:
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
 
Use the echo method described above to add the Logstash repository. Do not useadd-apt-repository as it will add a deb-src entry as well, but we do not provide a source package. If you have added the deb-src entry, you will see an error like the following:
Unable to find expected entry 'main/source/Sources' in Release file (Wrong sources.list entry or malformed file)
Just delete the deb-src entry from the /etc/apt/sources.list file and the installation should work as expected.
Run sudo apt-get update and the repository is ready for use. You can install it with:
sudo apt-get update && sudo apt-get install logstash
See Running Logstash for details about managing Logstash as a system service.
YUMedit
Download and install the public signing key:
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
Add the following in your /etc/yum.repos.d/ directory in a file with a .repo suffix, for examplelogstash.repo
[logstash-5.x]
name=Elastic repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
And your repository is ready for use. You can install it with:
sudo yum install logstash
 
The repositories do not work with older rpm based distributions that still use RPM v3, like CentOS5.
See the Running Logstash document for managing Logstash as a system service.
Dockeredit
An image is available for running Logstash as a Docker container. It is available from the Elastic Docker registry. See Running Logstash on Docker for details on how to configure and run Logstash Docker containers.

Stashing Your First Event | Logstash Reference [5.1] | Elastic 
https://www.elastic.co/guide/en/logstash/current/first-event.html

  Parsing Logs with Logstash  »
Stashing Your First Eventedit
First, let’s test your Logstash installation by running the most basic Logstash pipeline.
A Logstash pipeline has two required elements, input and output, and one optional element,filter. The input plugins consume data from a source, the filter plugins modify the data as you specify, and the output plugins write the data to a destination.
 
To test your Logstash installation, run the most basic Logstash pipeline:
cd logstash-5.1.1
bin/logstash -e 'input { stdin { } } output { stdout {} }'
The -e flag enables you to specify a configuration directly from the command line. Specifying configurations at the command line lets you quickly test configurations without having to edit a file between iterations. The pipeline in the example takes input from the standard input, stdin, and moves that input to the standard output, stdout, in a structured format.
After starting Logstash, wait until you see "Pipeline main started" and then enter hello world at the command prompt:
hello world
2013-11-21T01:22:14.405+0000 0.0.0.0 hello world
Logstash adds timestamp and IP address information to the message. Exit Logstash by issuing aCTRL-D command in the shell where Logstash is running.
Congratulations! You’ve created and run a basic Logstash pipeline. Next, you learn how to create a more realistic pipeline.



Parsing Logs with Logstash | Logstash Reference [5.1] | Elastic
 https://www.elastic.co/guide/en/logstash/current/advanced-pipeline.html

  Stitching Together Multiple Input and Output Plugins  »
Parsing Logs with Logstashedit
In Stashing Your First Event, you created a basic Logstash pipeline to test your Logstash setup. In the real world, a Logstash pipeline is a bit more complex: it typically has one or more input, filter, and output plugins.
In this section, you create a Logstash pipeline that uses Filebeat to take Apache web logs as input, parses those logs to create specific, named fields from the logs, and writes the parsed data to an Elasticsearch cluster. Rather than defining the pipeline configuration at the command line, you’ll define the pipeline in a config file.
To get started, go here to download the sample data set used in this example. Unpack the file.
Configuring Filebeat to Send Log Lines to Logstashedit
Before you create the Logstash pipeline, you’ll configure Filebeat to send log lines to Logstash. TheFilebeat client is a lightweight, resource-friendly tool that collects logs from files on the server and forwards these logs to your Logstash instance for processing. Filebeat is designed for reliability and low latency. Filebeat has a light resource footprint on the host machine, and the Beats inputplugin minimizes the resource demands on the Logstash instance.
 
In a typical use case, Filebeat runs on a separate machine from the machine running your Logstash instance. For the purposes of this tutorial, Logstash and Filebeat are running on the same machine.
The default Logstash installation includes the Beats input plugin. The Beats input plugin enables Logstash to receive events from the Elastic Beats framework, which means that any Beat written to work with the Beats framework, such as Packetbeat and Metricbeat, can also send event data to Logstash.
To install Filebeat on your data source machine, download the appropriate package from the Filebeat product page. You can also refer to Getting Started with Filebeat in the Beats documentation for additional installation instructions.
After installing Filebeat, you need to configure it. Open the filebeat.yml file located in your Filebeat installation directory, and replace the contents with the following lines. Make sure paths points to the example Apache log file, logstash-tutorial.log, that you downloaded earlier:
filebeat.prospectors:
- input_type: log
  paths:
    - /path/to/file/logstash-tutorial.log  
output.logstash:
  hosts: ["localhost:5043"]
 	Absolute path to the file or files that Filebeat processes.
Save your changes.
To keep the configuration simple, you won’t specify TLS/SSL settings as you would in a real world scenario.
At the data source machine, run Filebeat with the following command:
sudo ./filebeat -e -c filebeat.yml -d "publish"
Filebeat will attempt to connect on port 5043. Until Logstash starts with an active Beats plugin, there won’t be any answer on that port, so any messages you see regarding failure to connect on that port are normal for now.
Configuring Logstash for Filebeat Inputedit
Next, you create a Logstash configuration pipeline that uses the Beats input plugin to receive events from Beats.
The following text represents the skeleton of a configuration pipeline:
# The # character at the beginning of a line indicates a comment. Use
# comments to describe your configuration.
input {
}
# The filter part of this file is commented out to indicate that it is
# optional.
# filter {
#
# }
output {
}
This skeleton is non-functional, because the input and output sections don’t have any valid options defined.
To get started, copy and paste the skeleton configuration pipeline into a file named first-pipeline.conf in your home Logstash directory.
Next, configure your Logstash instance to use the Beats input plugin by adding the following lines to the input section of the first-pipeline.conf file:
    beats {
        port => "5043"
    }
You’ll configure Logstash to write to Elasticsearch later. For now, you can add the following line to the output section so that the output is printed to stdout when you run Logstash:
    stdout { codec => rubydebug }
When you’re done, the contents of first-pipeline.conf should look like this:
input {
    beats {
        port => "5043"
    }
}
# The filter part of this file is commented out to indicate that it is
# optional.
# filter {
#
# }
output {
    stdout { codec => rubydebug }
}
To verify your configuration, run the following command:
bin/logstash -f first-pipeline.conf --config.test_and_exit
The --config.test_and_exit option parses your configuration file and reports any errors.
If the configuration file passes the configuration test, start Logstash with the following command:
bin/logstash -f first-pipeline.conf --config.reload.automatic
The --config.reload.automatic option enables automatic config reloading so that you don’t have to stop and restart Logstash every time you modify the configuration file.
If your pipeline is working correctly, you should see a series of events like the following written to the console:
{
    "@timestamp" => 2016-10-11T20:54:06.733Z,
        "offset" => 325,
      "@version" => "1",
          "beat" => {
        "hostname" => "My-MacBook-Pro.local",
            "name" => "My-MacBook-Pro.local"
    },
    "input_type" => "log",
          "host" => "My-MacBook-Pro.local",
        "source" => "/path/to/file/logstash-tutorial.log",
       "message" => "83.149.9.216 - - [04/Jan/2015:05:13:42 +0000] \"GET /presentations/logstash-monitorama-2013/images/kibana-search.png HTTP/1.1\" 200 203023 \"http://semicomplete.com/presentations/logstash-monitorama-2013/\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
          "type" => "log",
          "tags" => [
        [0] "beats_input_codec_plain_applied"
    ]
}
...
Parsing Web Logs with the Grok Filter Pluginedit
Now you have a working pipeline that reads log lines from Filebeat. However you’ll notice that the format of the log messages is not ideal. You want to parse the log messages to create specific, named fields from the logs. To do this, you’ll use the grok filter plugin.
The grok filter plugin is one of several plugins that are available by default in Logstash. For details on how to manage Logstash plugins, see the reference documentation for the plugin manager.
The grok filter plugin enables you to parse the unstructured log data into something structured and queryable.
Because the grok filter plugin looks for patterns in the incoming log data, configuring the plugin requires you to make decisions about how to identify the patterns that are of interest to your use case. A representative line from the web server log sample looks like this:
83.149.9.216 - - [04/Jan/2015:05:13:42 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-search.png
HTTP/1.1" 200 203023 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel
Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"
The IP address at the beginning of the line is easy to identify, as is the timestamp in brackets. To parse the data, you can use the %{COMBINEDAPACHELOG} grok pattern, which structures lines from the Apache log using the following schema:
Information	Field Name
IP Address	clientip
User ID	ident
User Authentication	auth
timestamp	timestamp
HTTP Verb	verb
Request body	request
HTTP Version	httpversion
HTTP Status Code	response
Bytes served	bytes
Referrer URL	referrer
User agent	agent
Edit the first-pipeline.conf file and replace the entire filter section with the following text:
filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}"}
    }
}
When you’re done, the contents of first-pipeline.conf should look like this:
input {
    beats {
        port => "5043"
    }
}
filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}"}
    }
}
output {
    stdout { codec => rubydebug }
}
Save your changes. Because you’ve enabled automatic config reloading, you don’t have to restart Logstash to pick up your changes. However, you do need to force Filebeat to read the log file from scratch. To do this, go to the terminal window where Filebeat is running and press Ctrl+C to shut down Filebeat. Then delete the Filebeat registry file. For example, run:
sudo rm data/registry
Since Filebeat stores the state of each file it harvests in the registry, deleting the registry file forces Filebeat to read all the files it’s harvesting from scratch.
Next, restart Filebeat with the following command:
sudo ./filebeat -e -c filebeat.yml -d "publish"
After processing the log file with the grok pattern, the events will have the following JSON representation:
{
        "request" => "/presentations/logstash-monitorama-2013/images/kibana-search.png",
          "agent" => "\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
         "offset" => 325,
           "auth" => "-",
          "ident" => "-",
     "input_type" => "log",
           "verb" => "GET",
         "source" => "/path/to/file/logstash-tutorial.log",
        "message" => "83.149.9.216 - - [04/Jan/2015:05:13:42 +0000] \"GET /presentations/logstash-monitorama-2013/images/kibana-search.png HTTP/1.1\" 200 203023 \"http://semicomplete.com/presentations/logstash-monitorama-2013/\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
           "type" => "log",
           "tags" => [
        [0] "beats_input_codec_plain_applied"
    ],
       "referrer" => "\"http://semicomplete.com/presentations/logstash-monitorama-2013/\"",
     "@timestamp" => 2016-10-11T21:04:36.167Z,
       "response" => "200",
          "bytes" => "203023",
       "clientip" => "83.149.9.216",
       "@version" => "1",
           "beat" => {
        "hostname" => "My-MacBook-Pro.local",
            "name" => "My-MacBook-Pro.local"
    },
           "host" => "My-MacBook-Pro.local",
    "httpversion" => "1.1",
      "timestamp" => "04/Jan/2015:05:13:42 +0000"
}
Notice that the event includes the original message, but the log message is also broken down into specific fields.
Enhancing Your Data with the Geoip Filter Pluginedit
In addition to parsing log data for better searches, filter plugins can derive supplementary information from existing data. As an example, the geoip plugin looks up IP addresses, derives geographic location information from the addresses, and adds that location information to the logs.
Configure your Logstash instance to use the geoip filter plugin by adding the following lines to thefilter section of the first-pipeline.conf file:
    geoip {
        source => "clientip"
    }
The geoip plugin configuration requires you to specify the name of the source field that contains the IP address to look up. In this example, the clientip field contains the IP address.
Since filters are evaluated in sequence, make sure that the geoip section is after the grok section of the configuration file and that both the grok and geoip sections are nested within the filtersection.
When you’re done, the contents of first-pipeline.conf should look like this:
input {
    beats {
        port => "5043"
    }
}
 filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}"}
    }
    geoip {
        source => "clientip"
    }
}
output {
    stdout { codec => rubydebug }
}
Save your changes. To force Filebeat to read the log file from scratch, as you did earlier, shut down Filebeat (press Ctrl+C), delete the registry file, and then restart Filebeat with the following command:
sudo ./filebeat -e -c filebeat.yml -d "publish"
Notice that the event now contains geographic location information:
{
        "request" => "/presentations/logstash-monitorama-2013/images/kibana-search.png",
          "agent" => "\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
          "geoip" => {
              "timezone" => "Europe/Moscow",
                    "ip" => "83.149.9.216",
              "latitude" => 55.7522,
        "continent_code" => "EU",
             "city_name" => "Moscow",
         "country_code2" => "RU",
          "country_name" => "Russia",
              "dma_code" => nil,
         "country_code3" => "RU",
           "region_name" => "Moscow",
              "location" => [
            [0] 37.6156,
            [1] 55.7522
        ],
           "postal_code" => "101194",
             "longitude" => 37.6156,
           "region_code" => "MOW"
    },
    ...
Indexing Your Data into Elasticsearchedit
Now that the web logs are broken down into specific fields, the Logstash pipeline can index the data into an Elasticsearch cluster. Edit the first-pipeline.conf file and replace the entire outputsection with the following text:
output {
    elasticsearch {
        hosts => [ "localhost:9200" ]
    }
}
With this configuration, Logstash uses http protocol to connect to Elasticsearch. The above example assumes that Logstash and Elasticsearch are running on the same instance. You can specify a remote Elasticsearch instance by using the hosts configuration to specify something likehosts => [ "es-machine:9092" ].
At this point, your first-pipeline.conf file has input, filter, and output sections properly configured, and looks something like this:
input {
    beats {
        port => "5043"
    }
}
 filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}"}
    }
    geoip {
        source => "clientip"
    }
}
output {
    elasticsearch {
        hosts => [ "localhost:9200" ]
    }
}
Save your changes. To force Filebeat to read the log file from scratch, as you did earlier, shut down Filebeat (press Ctrl+C), delete the registry file, and then restart Filebeat with the following command:
sudo ./filebeat -e -c filebeat.yml -d "publish"
Testing Your Pipelineedit
Now that the Logstash pipeline is configured to index the data into an Elasticsearch cluster, you can query Elasticsearch.
Try a test query to Elasticsearch based on the fields created by the grok filter plugin. Replace $DATE with the current date, in YYYY.MM.DD format:
curl -XGET 'localhost:9200/logstash-$DATE/_search?pretty&q=response=200'
 
The date used in the index name is based on UTC, not the timezone where Logstash is running. If the query returns index_not_found_exception, make sure that logstash-$DATE reflects the actual name of the index. To see a list of available indexes, use this query: curl 'localhost:9200/_cat/indices?v'.
You should get multiple hits back. For example:
{
  "took" : 21,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 98,
    "max_score" : 3.745223,
    "hits" : [
      {
        "_index" : "logstash-2016.10.11",
        "_type" : "log",
        "_id" : "AVe14gMiYMkU36o_eVsA",
        "_score" : 3.745223,
        "_source" : {
          "request" : "/presentations/logstash-monitorama-2013/images/frontend-response-codes.png",
          "agent" : "\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
          "geoip" : {
            "timezone" : "Europe/Moscow",
            "ip" : "83.149.9.216",
            "latitude" : 55.7522,
            "continent_code" : "EU",
            "city_name" : "Moscow",
            "country_code2" : "RU",
            "country_name" : "Russia",
            "dma_code" : null,
            "country_code3" : "RU",
            "region_name" : "Moscow",
            "location" : [
              37.6156,
              55.7522
            ],
            "postal_code" : "101194",
            "longitude" : 37.6156,
            "region_code" : "MOW"
          },
          "offset" : 2932,
          "auth" : "-",
          "ident" : "-",
          "input_type" : "log",
          "verb" : "GET",
          "source" : "/path/to/file/logstash-tutorial.log",
          "message" : "83.149.9.216 - - [04/Jan/2015:05:13:45 +0000] \"GET /presentations/logstash-monitorama-2013/images/frontend-response-codes.png HTTP/1.1\" 200 52878 \"http://semicomplete.com/presentations/logstash-monitorama-2013/\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36\"",
          "type" : "log",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "referrer" : "\"http://semicomplete.com/presentations/logstash-monitorama-2013/\"",
          "@timestamp" : "2016-10-11T22:34:25.317Z",
          "response" : "200",
          "bytes" : "52878",
          "clientip" : "83.149.9.216",
          "@version" : "1",
          "beat" : {
            "hostname" : "My-MacBook-Pro.local",
            "name" : "My-MacBook-Pro.local"
          },
          "host" : "My-MacBook-Pro.local",
          "httpversion" : "1.1",
          "timestamp" : "04/Jan/2015:05:13:45 +0000"
        }
      }
    },
    ...
Try another search for the geographic information derived from the IP address. Replace $DATE with the current date, in YYYY.MM.DD format:
curl -XGET 'localhost:9200/logstash-$DATE/_search?pretty&q=geoip.city_name=Buffalo'
A few log entries come from Buffalo, so the query produces the following response:
{
  "took" : 3,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 3,
    "max_score" : 2.6390574,
    "hits" : [
      {
        "_index" : "logstash-2016.10.11",
        "_type" : "log",
        "_id" : "AVe14gMjYMkU36o_eVtO",
        "_score" : 2.6390574,
        "_source" : {
          "request" : "/?flav=rss20",
          "agent" : "\"-\"",
          "geoip" : {
            "timezone" : "America/New_York",
            "ip" : "108.174.55.234",
            "latitude" : 42.9864,
            "continent_code" : "NA",
            "city_name" : "Buffalo",
            "country_code2" : "US",
            "country_name" : "United States",
            "dma_code" : 514,
            "country_code3" : "US",
            "region_name" : "New York",
            "location" : [
              -78.7279,
              42.9864
            ],
            "postal_code" : "14221",
            "longitude" : -78.7279,
            "region_code" : "NY"
          },
          "offset" : 21471,
          "auth" : "-",
          "ident" : "-",
          "input_type" : "log",
          "verb" : "GET",
          "source" : "/path/to/file/logstash-tutorial.log",
          "message" : "108.174.55.234 - - [04/Jan/2015:05:27:45 +0000] \"GET /?flav=rss20 HTTP/1.1\" 200 29941 \"-\" \"-\"",
          "type" : "log",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "referrer" : "\"-\"",
          "@timestamp" : "2016-10-11T22:34:25.318Z",
          "response" : "200",
          "bytes" : "29941",
          "clientip" : "108.174.55.234",
          "@version" : "1",
          "beat" : {
            "hostname" : "My-MacBook-Pro.local",
            "name" : "My-MacBook-Pro.local"
          },
          "host" : "My-MacBook-Pro.local",
          "httpversion" : "1.1",
          "timestamp" : "04/Jan/2015:05:27:45 +0000"
        }
      },
     ...
If you are using Kibana to visualize your data, you can also explore the Filebeat data in Kibana:
 
See the Filebeat getting started docs for info about loading the Kibana index pattern for Filebeat.
You’ve successfully created a pipeline that uses Filebeat to take Apache web logs as input, parses those logs to create specific, named fields from the logs, and writes the parsed data to an Elasticsearch cluster. Next, you learn how to create a pipeline that uses multiple input and output plugins.



Stitching Together Multiple Input and Output Plugins | Logstash Reference [5.1] | Elastic 
https://www.elastic.co/guide/en/logstash/current/multiple-input-output-plugins.html


Stitching Together Multiple Input and Output Pluginsedit
The information you need to manage often comes from several disparate sources, and use cases can require multiple destinations for your data. Your Logstash pipeline can use multiple input and output plugins to handle these requirements.
In this section, you create a Logstash pipeline that takes input from a Twitter feed and the Filebeat client, then sends the information to an Elasticsearch cluster as well as writing the information directly to a file.
Reading from a Twitter Feededit
To add a Twitter feed, you use the twitter input plugin. To configure the plugin, you need several pieces of information:
•	A consumer key, which uniquely identifies your Twitter app.
•	A consumer secret, which serves as the password for your Twitter app.
•	One or more keywords to search in the incoming feed. The example shows using "cloud" as a keyword, but you can use whatever you want.
•	An oauth token, which identifies the Twitter account using this app.
•	An oauth token secret, which serves as the password of the Twitter account.
Visit https://dev.twitter.com/apps to set up a Twitter account and generate your consumer key and secret, as well as your access token and secret. See the docs for the twitter input plugin if you’re not sure how to generate these keys.
Like you did earlier when you worked on Parsing Logs with Logstash, create a config file (calledsecond-pipeline.conf) that contains the skeleton of a configuration pipeline. If you want, you can reuse the file you created earlier, but make sure you pass in the correct config file name when you run Logstash.
Add the following lines to the input section of the second-pipeline.conf file, substituting your values for the placeholder values shown here:
    twitter {
        consumer_key => "enter_your_consumer_key_here"
        consumer_secret => "enter_your_secret_here"
        keywords => ["cloud"]
        oauth_token => "enter_your_access_token_here"
        oauth_token_secret => "enter_your_access_token_secret_here"
    }
Configuring Filebeat to Send Log Lines to Logstashedit
As you learned earlier in Configuring Filebeat to Send Log Lines to Logstash, the Filebeat client is a lightweight, resource-friendly tool that collects logs from files on the server and forwards these logs to your Logstash instance for processing.
After installing Filebeat, you need to configure it. Open the filebeat.yml file located in your Filebeat installation directory, and replace the contents with the following lines. Make sure paths points to your syslog:
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/*.log  
  fields:
    type: syslog  
output.logstash:
  hosts: ["localhost:5043"]
 	Absolute path to the file or files that Filebeat processes.
 	Adds a field called type with the value syslog to the event.
Save your changes.
To keep the configuration simple, you won’t specify TLS/SSL settings as you would in a real world scenario.
Configure your Logstash instance to use the Filebeat input plugin by adding the following lines to the input section of the second-pipeline.conf file:
    beats {
        port => "5043"
    }
Writing Logstash Data to a Fileedit
You can configure your Logstash pipeline to write data directly to a file with the file output plugin.
Configure your Logstash instance to use the file output plugin by adding the following lines to theoutput section of the second-pipeline.conf file:
    file {
        path => "/path/to/target/file"
    }
Writing to Multiple Elasticsearch Nodesedit
Writing to multiple Elasticsearch nodes lightens the resource demands on a given Elasticsearch node, as well as providing redundant points of entry into the cluster when a particular node is unavailable.
To configure your Logstash instance to write to multiple Elasticsearch nodes, edit the outputsection of the second-pipeline.conf file to read:
output {
    elasticsearch {
        hosts => ["IP Address 1:port1", "IP Address 2:port2", "IP Address 3"]
    }
}
Use the IP addresses of three non-master nodes in your Elasticsearch cluster in the host line. When the hosts parameter lists multiple IP addresses, Logstash load-balances requests across the list of addresses. Also note that the default port for Elasticsearch is 9200 and can be omitted in the configuration above.
Testing the Pipelineedit
At this point, your second-pipeline.conf file looks like this:
input {
    twitter {
        consumer_key => "enter_your_consumer_key_here"
        consumer_secret => "enter_your_secret_here"
        keywords => ["cloud"]
        oauth_token => "enter_your_access_token_here"
        oauth_token_secret => "enter_your_access_token_secret_here"
    }
    beats {
        port => "5043"
    }
}
output {
    elasticsearch {
        hosts => ["IP Address 1:port1", "IP Address 2:port2", "IP Address 3"]
    }
    file {
        path => "/path/to/target/file"
    }
}
Logstash is consuming data from the Twitter feed you configured, receiving data from Filebeat, and indexing this information to three nodes in an Elasticsearch cluster as well as writing to a file.
At the data source machine, run Filebeat with the following command:
sudo ./filebeat -e -c filebeat.yml -d "publish"
Filebeat will attempt to connect on port 5043. Until Logstash starts with an active Beats plugin, there won’t be any answer on that port, so any messages you see regarding failure to connect on that port are normal for now.
To verify your configuration, run the following command:
bin/logstash -f second-pipeline.conf --config.test_and_exit
The --config.test_and_exit option parses your configuration file and reports any errors. When the configuration file passes the configuration test, start Logstash with the following command:
bin/logstash -f second-pipeline.conf
Use the grep utility to search in the target file to verify that information is present:
grep syslog /path/to/target/file
Run an Elasticsearch query to find the same information in the Elasticsearch cluster:
curl -XGET 'localhost:9200/logstash-$DATE/_search?pretty&q=fields.type:syslog'
Replace $DATE with the current date, in YYYY.MM.DD format.
To see data from the Twitter feed, try this query:
curl -XGET 'http://localhost:9200/logstash-$DATE/_search?pretty&q=client:iphone'
Again, remember to replace $DATE with the current date, in YYYY.MM.DD format.


