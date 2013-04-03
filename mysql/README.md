Template MySQL
============

Show MySQL statistics in Zabbix.

INSTALL
-------

Assume the Zabbix agent is installed in /zabbix-agent/ directory.

### Preparatory

This package uses `mysql` and `mysqladmin` commands to gather information of MySQL.

### Install Script and Add User Parameters

Copy mysql-check.sh to /zabbix-agent/bin/. Copy mysql-params.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/. Restart Zabbix agent.

Edit mysql-check.sh to configure username and password.

### Import Template

Import mysql-template.xml, and link it to a host.

HOW IT WORKS
------------

### mysqladmin

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

