#!/bin/bash

MYSQL_USERNAME="root"
MYSQL_PASSWORD="password"
MYSQL_PORTS="3306" # use space-seperated multiple instance ports

MYSQL_VARIABLES="Connections Aborted_clients Aborted_connects Com_select Com_insert Com_update Com_replace Com_delete Slow_queries Threads_connected Threads_running"

ZABBIX_HOME="/usr/local/zabbix-agent-ops"
ZABBIX_BIN="$ZABBIX_HOME/bin/zabbix_sender -c $ZABBIX_HOME/etc/zabbix_agentd.conf"

function usage() {
    echo "Usage: ./mysql-check-v2.sh <discovery|collector> [host] [port]"
    exit 1
}

if [ "x$1" = "xdiscovery" ]; then

    COUNT=`echo "$MYSQL_PORTS" | wc -w`
    INDEX=0
    echo '{"data":['
    for MYSQL_PORT in $MYSQL_PORTS; do
        echo -n '{"{#MYSQL_PORT}":"'$MYSQL_PORT'"}'
        INDEX=`expr $INDEX + 1`
        if [ $INDEX -lt $COUNT ]; then
            echo ','
        fi
    done
    echo ']}'

elif [ "x$1" = "xcollector" ]; then

    if [ -z $2 ] || [ -z $3 ]; then
        usage
    fi

    HOST_HOST=$2
    MYSQL_PORT=$3

    EXTENDED_STATUS=`mysqladmin -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h127.0.0.1 -P$MYSQL_PORT extended-status`

    DATA=""
    for MYSQL_VARIABLE in $MYSQL_VARIABLES; do
        VALUE=`echo "$EXTENDED_STATUS" | grep -w "$MYSQL_VARIABLE" | awk '{print $4}'`
        if [ -n "$VALUE" ]; then
            DATA=$DATA"- mysql-v2.check[$MYSQL_PORT,$MYSQL_VARIABLE] $VALUE\n"
        fi
    done

    REPLICATION_DELAY=`mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h127.0.0.1 -P$MYSQL_PORT -Dheartbeat_db -e "SELECT UNIX_TIMESTAMP() - UNIX_TIMESTAMP(ts) FROM heartbeat ORDER BY id DESC LIMIT 1" | sed '1d'`

    if [ -n "$REPLICATION_DELAY" ]; then
        DATA=$DATA"- mysql-v2.check[$MYSQL_PORT,Replication_delay] $REPLICATION_DELAY\n"
    fi

    if [ -n "$DATA" ]; then
        echo -e "$DATA" | $ZABBIX_BIN -s "$HOST_HOST" -i- >/dev/null 2>&1
        echo 1
    else
        echo 0
    fi

else
    usage
fi
