#!/bin/bash
HOST=$1
USERNAME=$2
PASSWORD=$3
PEER_NAME=$4
PEER_FIELD_NAME=$5
API_CALL="/routing/bgp/peer/print\n?name=$PEER_NAME\n"
API_ROS_COMMAND="/home/zabbix/externalscripts/apiros.py"

PEER_FIELD=$(echo -e "$API_CALL" | $API_ROS_COMMAND "$HOST" "$USERNAME" "$PASSWORD" | grep "$PEER_FIELD_NAME" | cut -d "=" -f 3)

if [ "$PEER_FIELD_NAME" == "state" ]; then
	if [ "$PEER_FIELD" == "established" ]; then
		echo 3

	elif [ "$PEER_FIELD" == "active" ]; then
		echo 2

	elif [ "$PEER_FIELD" == "opensent" ] || [ "$PEER_FIELD" == "openconfirm" ]; then
		echo 1

	elif [ "$PEER_FIELD" == "idle" ]; then
		echo 0
	else
		echo
	fi
else
	DAY=$(echo -e "$PEER_FIELD" | cut -d "d" -f1)

	HOURS=$(echo -e "$PEER_FIELD" | cut -d "d" -f2 | cut -d "h" -f1)

	MINUTES=$(echo -e "$PEER_FIELD" | cut -d "h" -f2 | cut -d "m" -f1)

	SECONDS=$(echo -e "$PEER_FIELD" | cut -d "m" -f2 | cut -d "s" -f1)

	DAY_TO_SECONDS=$(($DAY * 86400))

	HOURS_TO_SECONDS=$(($HOURS * 3600))

	MINUTES_TO_SECONDS=$(($MINUTES * 60))

	SUM_SECONDS=$(($DAY_TO_SECONDS + $HOURS_TO_SECONDS + $MINUTES_TO_SECONDS + $SECONDS))
	
	echo $SUM_SECONDS
fi
