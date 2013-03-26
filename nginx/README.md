Template Nginx
==============

Show Nginx status in Zabbix.

INSTALL
-------

Assume the Zabbix agent is installed in /zabbix-agent/ directory.

### Nginx HttpStubStatusModule

Nginx needs to be built with HttpStubStatusModule, i.e. --with-http_stub_status_module. You can use `nginx -V` to check whether the current binary includes this module.

More information could be found in this [Wiki][1]

### Add Configuration

Add the following into Nginx configuration:

<pre>
server {
    listen 10061;
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
</pre>

Reload Nginx, and use `curl http://127.0.0.1:10061/nginx_status` to get the statistics.

### Add User Parameters

Copy nginx-params.conf to /zabbix-agent/etc/zabbix_agentd.conf.d/. Restart Zabbix agent.

### Import Template

Import nginx-template.xml, and link it to a host. Set the host macro {$NGINX_STATUS_URL} if needed.


CREDITS
-------

The scripts are form http://github.com/zbal/zabbix.

[1]: http://wiki.nginx.org/HttpStubStatusModule
