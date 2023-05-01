#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi
source /etc/monitor-scripts/dashboard.ini
echo ${CFG_PEER_LIST_VALUE} > /var/dashboard/statuses/peerlist
