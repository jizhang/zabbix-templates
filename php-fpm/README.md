Template php-fpm
================

Show php-fpm statistics in Zabbix.

INSTALL
-------

Assume the Zabbix agent is installed in /zabbix-agent/ directory.

### Configure php-fpm

Open the php-fpm pool's configuration file, uncomment the 'pm.status=' directive:

pm.status_path = /php-fpm_status

Since php-fpm's statistics is collected by different pools, so you need to create corresponding hosts for them.

### Configure Nginx

Add the following lines to Nginx configuration:

```
server {
    listen 10061;

    location /php-fpm_status {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

After restarting both php-fpm and nginx, try the following command to test:

$ curl http://127.0.0.1:10061/php-fpm_status

### Add User Parameters

Copy php-fpm-params.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/. Restart Zabbix agent.

### Import Template

Import php-fpm-template.xml, and link it to a host. Set the host macro {$PHP_FPM_STATUS_URL} if needed.


CREDITS
-------

Some of the scripts are form http://github.com/zbal/zabbix.

