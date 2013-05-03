Template JVM
============

Show JVM statistics in Zabbix.

INSTALL
-------

Assume the Zabbix agent is installed in /zabbix-agent/ directory.

### A Compatible JDK

This package uses `jstat` and `jstack` commands to gather information of jVM.

### Start Daemon

Since the Zabbix agent runs in zabbix user, making it impossible to attache to JVMs running under other users. The solution is to start a daemon under that user and provide socket access to gather the information.

$ ./jvm-service.pl -d

It will write logs into /tmp/jvm-service.log

### Install Script and Add User Parameters

Copy jvm-check.pl to /zabbix-agent/bin/. Copy jvm-params.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/. Restart Zabbix agent.

### Import Template

Import jvm-template.xml, and link it to a host. Set the host macro {$JVMPORT} to which the JVM you want to monitor bind.

HOW IT WORKS
------------

To gather information more effectively, I didn't use a lot of user parameters in the configuration file, to run multiple times. Instead, I used the 'zabbix agent trapper' data type, and run another script sending multiple data items to zabbix server.

Again, instead of setup a cron job for the script, I used another 'zabbix agent' data type to let the server trigger this script.

In case the `jstat` command spends more than 3 seconds, which surpasses the timeout limit of Zabbix, so you may want to adjust the `Timeout` option in *both* Zabbix server and agent configuration.

