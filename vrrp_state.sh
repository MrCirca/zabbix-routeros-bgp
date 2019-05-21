#!/bin/bash
HOST=$1
USERNAME=$2
PASSWORD=$3

API_VRRP_STATE_CALL="/interface/vrrp/print"
API_ROS_COMMAND="/tmp/zabbix-routeros-bgp/apiros.py"
VRRP_STATE_CONN=$(echo -e "$API_VRRP_STATE_CALL" | "$API_ROS_COMMAND" "$HOST" "$USERNAME" "$PASSWORD")

VRRP_STATE=$(echo -e "$VRRP_STATE_CONN" | grep "=master" | cut -d "=" -f 3)

if [ "$VRRP_STATE" == "true" ]; then
    echo 1
else
    echo 0
fi
