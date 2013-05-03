Template MySQL
============

Show MySQL statistics in Zabbix. Version 2 uses LLD (Low Level Discovery) to bind multiple MySQL instances to the same host.

INSTALL
-------

Assume the Zabbix agent is installed in /zabbix-agent/ directory.

### Preparatory

This package uses `mysql` and `mysqladmin` commands to gather information of MySQL.

### Install Script and Add User Parameters

* Copy mysql-check-v2.sh to /zabbix-agent/bin/.
* Copy mysql-params-v2.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/.
* Edit mysql-check-v2.sh to configure username and password.
* Restart Zabbix agent.

### Import Template

Import mysql-template-v2.xml, and link it to a host.

HOW IT WORKS
------------

### Discovery

`mysql-check-v2.sh` has two forms of invocation:

* `./mysql-check-v2.sh discovery` Return a JSON encoded string indicating the MySQL instances (or ports) to be discovered.
* `./mysql-check-v2.sh collector "$host" $port` Get and submit the statistics from MySQL Server to Zabbix Server. (use `zabbix trapper` data type)

### Collector

In order not to run `mysqladmin` several times to get enough information, here we use `Zabbix trapper` data type to let the agent send data actively. Also to save the trouble of adding a cron job, here we use a `Zabbix agent` item to trigger the data collection process.

### `mysqladmin`

Most statistics items are from `mysqladmin extended-status`.

### Replication Delay

To detect the replication delay (in sec) of Slave database, we use a dedicated `heartbeat_db`, in which the Master database update the timestamp periodically, and the Slave agents check the difference between current timestamp and the heartbeat_db's timestamp.

The `heartbeat_db.heartbeat` table's structure is:

```sql
CREATE TABLE `heartbeat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ts` datetime NOT NULL,
  RIMARY KEY (`id`)
)
```
