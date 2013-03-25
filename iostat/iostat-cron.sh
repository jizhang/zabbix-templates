#!/bin/bash
##################################
# Zabbix monitoring script
#
# Info:
#  - cron job to gather iostat data
#  - can not do real time as iostat data gathering will exceed 
#    Zabbix agent timeout
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922	VV	initial creation
##################################

# source data file
DEST_DATA=/usr/local/zabbix-agent-ops/var/iostat-data
TMP_DATA=/usr/local/zabbix-agent-ops/var/iostat-data.tmp

#
# gather data in temp file first, then move to final location
# it avoids zabbix-agent to gather data from a half written source file
#
# iostat -kx 10 2 - will display 2 lines :
#  - 1st: statistics since boot -- useless
#  - 2nd: statistics over the last 10 sec
#
iostat -kx 10 2 > $TMP_DATA
mv $TMP_DATA $DEST_DATA


