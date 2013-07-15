#!/bin/bash

DEVICES=`iostat | awk '{ if ($1 ~ "^([shxv]|xv)d[a-z]$") { print $1 } }'`

COUNT=`echo "$DEVICES" | wc -l`
INDEX=0
echo '{"data":['
echo "$DEVICES" | while read LINE; do
    echo -n '{"{#DEVNAME}":"'$LINE'"}'
    INDEX=`expr $INDEX + 1`
    if [ $INDEX -lt $COUNT ]; then
        echo ','
    fi
done
echo ']}'

