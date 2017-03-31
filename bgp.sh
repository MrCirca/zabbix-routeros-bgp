#!/bin/bash
NAME=$1
HOSTNAME=$2
USERNAME=$3
PASSWORD=$4
echo -e "/routing/bgp/peer/print\n=count-only=?name=$NAME\n" | /home/zabbix/externalscripts/apiros.py $HOSTNAME $USERNAME $PASSWORD | grep "=ret=" | cut -d "=" -f 3
