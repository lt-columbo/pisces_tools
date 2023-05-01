#!/bin/bash
source /etc/monitor-scripts/dashboard.ini
echo ${CFG_PEER_LIST_VALUE} > /var/dashboard/statuses/peerlist
