Template Hadoop
===============

Collect Hadoop statistics, both cluster-wise and for individual nodes, and display them with different templates and screens Zabbix.

INSTALL
-------

Assume the Zabbix agent is installed in /zabbix-agent/ directory.

### Preparatory

This package requires `Python 2.7`. For legacy Linux distributions, it's recommended to install Python in a standalone directory, e.g. `/usr/local/python-2.7`.

### Install Script and Add User Parameters

* Copy hadoop-collector.py to /zabbix-agent/bin/, and set it to `755`.
* Copy hadoop-params.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/.
* Restart Zabbix agent.

### Import Template

Import the following templates and apply them to the corresponding servers:

* hadoop-namenode-template.xml
* hadoop-jobtracker-template.xml
* hadoop-datanode-template.xml
* hadoop-tasktracker-template.xml

And the `hadoop-basic-template.xml` consists of cluster-wise data aggregation items, so it should be applied to the master node.

HOW IT WORKS
------------

### Data Source

All statistics are parsed from the Hadoop status page, i.e. `http://host:50030` and `https://host:50070`.

The server basic monitoring data is from Zabbix agent and other templates in this repo, like [iostat][1].

### Collector

In order not to parse the status page several times to get enough information, here we use `Zabbix trapper` data type to let the agent send data actively. Also to save the trouble of adding a cron job, here we use a `Zabbix agent` item to trigger the data collection process.

[1]: https://github.com/jizhang/zabbix-templates/tree/master/iostat

