

# https://ahus1.github.io/hystrix-examples/manual.html#_long_term_monitoring_of_hystrix_metrics

14. Long term monitoring of Hystrix metrics
14.1. Zabbix as classic long term monitoring and notification
Zabbix is a classic monitoring system. It is stable and it has grown over several iterations. It supports a REST API out of the box.

All data is stored in a database. The server polls information from clients, runs commands or receives information from agents.

A frontend service will provide a web interface that includes configuration, monitoring and graphing capabilities.

14.2. Installing and running Zabbix
The installation has been scripted as a Vagrant script. This will first download a linux image of CentOS and spin it up in Virtualbox. Then it will hand over to a provisioner, in our case this is Saltstack.

To install Vagrant please see Running virtual machines for test and development. Once it is installed, run the follwing command in tools/zabbix:

vagrant up
This will take a while to download all the files necessary. Once it is up and running point your browser at your local Zabbix installation: http://localhost:2280/zabbix.

Use Username Admin password zabbix to log in (please note the capital A in the user name)

14.3. Configuration of Zabbix
All configuration items could be automated using the REST API. This will be a future task for this tutorial.

For now these are the manual steps:

In Configuration ▸ Templates click on Import. Pick the file hystrix_template.xml from tools\zabbix. Click on Import.

Choose Configuration ▸ Templates again. You see a hystrixTemplate here. Click on this template to edit it. Include the host hystrix in group Discovered Hosts in the shuttle view to put it on the left side. This will apply the template to the host. Click on Save.

In Configuration ▸ Host click on Create Host. Enter hystrix as host name here. Pick Discovered Hosts as the Host group. Now Save.

This is all configuration that is needed: You have created a host, and you have associated it with a template that will autodiscover all Hystrix comamnds.

14.4. Configuration of the example application
As default the Zabbix agent in the application is disabled. To enable it, go to the file archaius.properties. Change the hystrixdemo.enablezabbix to be true.

The change is active at runtime. This will trigger the activation in HystrixSetupListener.

14.5. Zabbix autodiscovery at work
The following steps will now happen automatically:

The Zabbix agent will connect to 127.0.0.1:10051 and identifies itself as host hystrix. In our example this is hardcoded.

The Zabbix agent asks the server for any scheduled checks. The only check that is configured for the host hystrix is the hystrixCommand.discovery in the template.

The agent runs the check and delivers all active Hystrix commands as a JSON object to the server.

This will trigger the auto discovery. For every command Zabbix will create 20 items and three graphs.

When the Zabbix agent reloads the list of checks after a minute, there will be a lot more checks. It will run them as specified in the interval of the template we imported to Zabbix.

The auto discovery rule is set to run every five seconds. Please note that the auto discovery will only find commands that have been triggered at least once during the runtime of the application. Hystrix will only notify our Zabbix agent at the first created command.

Please choose Configuration ▸ Hosts and you should see the number of Items change for the host hystrix. Please refresh your browser if necessary.

Now choose Monitoring ▸ Graphs and choose the host hystrix and any of the three graphs. After a few minutes you should see the first graphs appearing. The following screen shows a service that was answering successfully first. After a short time the response time was changed to 250 ms. Soon lots of rejected and timeout requests appear.

Zabbix counting Hystrix requests
Figure 8. Zabbix counting Hystrix requests
Zabbix polls for the command data every minute. Change the timing in archaius.properties to see information about failed requests.

Click on Monitoring ▸ Latest data to see the latest values that the agent has sent.

14.6. Java classes to forward information from Hystrix to Zabbix
In order to activate the forwarding of events, you’ll need to change hystrixdemo.enablezabbix to true in archaius.properties. This change will be active immediately.

The property hystrixdemo.enablezabbix in archaius.properties is evaluated in the class HystrixSetupListener. When this property is enabled, the Zabbix agent is started.

You find all additional classes in the package de.ahus1.hystrix.util.zabbix in the example application. The following classes work together to forward the information to Zabbix:

ZabbixCommandMetricsProvider is registered with Zabbix. It handles the connection to Zabbix. It creates a callback ZabbixCommandMetricsProvider that will be called by the agent when it requires data for the provider hystrixCommand. It creates for Zabbix on request a HystrixZabbixMetricsPublisherCommand when a command is created for the first time.

Once the HystrixZabbixMetricsPublisherCommand initialized, it registers itself with the ZabbixCommandMetricsProvider.

The ZabbixCommandMetricsProvider will provide a list of HystrixCommand keys when it is called with hystrixCommand.discovery When it is called hystrixCommand.countSuccess[{#COMMAND}] it returns the current count of successful Hystrix command calls.

The current implementation doesn’t return any information about thread pools yet.

14.7. Working with templates in Zabbix
When you change your template, the changes are applied to all hosts assigned to the template. This makes it easy to ensure a common configuration of all Hystrix commands throughout your infrastructure.

You can also choose to setup triggers automatically.

When a command is no longer used in your application, the auto discovery will no longer return it to Hystrix. Hystrix will remove all items that are no longer needed after 30 days. You can simulate this behaviour by stopping/starting the tomcat server and not sending any requests via JMeter. As now commands will be triggered, the list of auto-discovered commands is empty. A few seconds later Zabbix will add a yellow exclamation mark to your items and will start the 30 day countdown.