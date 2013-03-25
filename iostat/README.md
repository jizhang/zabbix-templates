Template iostat
===============

Show `iostat` result in Zabbix.


INSTALL
-------

Assume the Zabbix agent directory is /zabbix-agent/.

### Install Cron Job

Since the first output of `iostat` is the statistics since boot time, we need to wait for a period (like 10 seconds) to get the result, which should be done through cron job, otherwise it'll surpass the zabbix agent's timeout.

Do the following two steps:

1. Copy iostat-cron.sh to /zabbix-agent/bin/;
2. Copy iostat-cron.conf to /etc/cron.d/;

After a while, you'll see the iostat-data file in /zabbix-agent/var/.

### Install User Parameters

To expose the iostat-data to Zabbix, do the following steps:

1. Copy dev-discovery.sh and iostat-check.sh to /zabbix-agent/bin/, the former one is to enable disk device discovery capability.
2. Copy iostat-params.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/.

### Import Template

Import iostat-template.xml, and link it to a host.


CREDITS
-------

Some of the scripts are from https://github.com/zbal/zabbix.

