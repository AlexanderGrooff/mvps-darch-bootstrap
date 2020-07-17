#!/bin/bash

SERVER_IP=$1

[ -z $1 ] && echo "No IP address found" && exit 1
echo "Bootstrapping darch on MVPS server $SERVER_IP"

scp mvps_darch_setup_1.sh root@$SERVER_IP:/tmp
ssh root@$SERVER_IP /tmp/mvps_darch_setup_1.sh
# Wait for reboot to finish
sleep 30

scp mvps_darch_setup_2.sh root@$SERVER_IP:/tmp
ssh root@$SERVER_IP /tmp/mvps_darch_setup_2.sh
