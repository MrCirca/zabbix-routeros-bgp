#!/bin/bash
HOST=$1
USERNAME=$2
PASSWORD=$3
PEER_NAME=$4
PEER_FIELD_NAME=$5
API_CALL="/routing/bgp/peer/print\n?name=$PEER_NAME\n"
API_ROS_COMMAND=$(cat /etc/zabbix/zabbix_server.conf | grep "^ExternalScripts=" | cut -d "=" -f 2)/apiros.py
PEER_FIELD=$(echo -e "$API_CALL" | "$API_ROS_COMMAND" "$HOST" "$USERNAME" "$PASSWORD" | grep "$PEER_FIELD_NAME" | cut -d "=" -f 3)

if [ "$PEER_FIELD_NAME" == "state" ]; then
	if [ "$PEER_FIELD" == "established" ]; then
		echo 4

	elif [ "$PEER_FIELD" == "active" ]; then
		echo 3

	elif [ "$PEER_FIELD" == "opensent" ] || [ "$PEER_FIELD" == "openconfirm" ]; then
		echo 2

	elif [ "$PEER_FIELD" == "idle" ]; then
		echo 1
	else
                echo 0
	fi

elif [ "$PEER_FIELD_NAME" == "uptime" ]; then
	if [ "$PEER_FIELD" == "" ]; then
		echo 0
	else
		WEEKS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+w' | tr -d 'w')
		WEEKS=${WEEKS:-0}

		DAYS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+d' | tr -d 'd')
		DAYS=${DAYS:-0}

		HOURS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+h' | tr -d 'h')
		HOURS=${HOURS:-0}

		MINUTES=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+m' | tr -d 'm')
		MINUTES=${MINUTES:-0}

		SECONDS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+s' | tr -d 's')
		SECONDS=${SECONDS:-0}

		TOTAL_SECONDS=$(echo "$WEEKS * 604800 + $DAYS * 86400 + $HOURS * 3600 + $MINUTES * 60 + $SECONDS" | bc)

		echo $TOTAL_SECONDS
	fi
else
	echo "$FIELD_NAME is not supported"
fi
