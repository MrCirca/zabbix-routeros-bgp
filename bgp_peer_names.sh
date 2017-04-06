#!/bin/bash
HOST=$1
USERNAME=$2
PASSWORD=$3

API_CALL="/routing/bgp/peer/print\n=status=\n"
API_ROS_COMMAND="/home/zabbix/externalscripts/apiros.py"

PEERS_STATUS=$(echo -e "$API_CALL" | $API_ROS_COMMAND "$HOST" "$USERNAME" "$PASSWORD")
PEER_NAMES=$(echo -e "$PEERS_STATUS" | grep -E -o '=name=[^ ]+' | cut -d "=" -f 3 | sed 's,\n, ,g')

PEER_NAMES_JSON="{\n    \"data\":["

for PEER_NAME in $PEER_NAMES
do
	PEER_NAMES_JSON="$PEER_NAMES_JSON\n        { \"{#BGP_PEER_NAME}\":\"$PEER_NAME\" },"
done

PEER_NAMES_JSON=$(echo -n "$PEER_NAMES_JSON" | head -c '-1')

PEER_NAMES_JSON="$PEER_NAMES_JSON\n    ]\n}"

echo -e "$PEER_NAMES_JSON"
