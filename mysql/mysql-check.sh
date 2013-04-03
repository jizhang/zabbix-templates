#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
    exit 1
fi

HOST_HOST=$1
QUERY_KEY=$2

if [ "x$QUERY_KEY" = "xReplication_delay" ]; then

    mysql -uroot -ppassword -h127.0.0.1 -P3306 -Dheartbeat_db -e "SELECT UNIX_TIMESTAMP() - UNIX_TIMESTAMP(ts) FROM heartbeat ORDER BY id DESC LIMIT 1" | sed '1d'

else

    mysqladmin -uroot -ppassword -h127.0.0.1 -P3306 extended-status | grep -w "$QUERY_KEY" | awk '{print $4}'

fi

