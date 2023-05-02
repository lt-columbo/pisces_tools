#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi
cp /etc/monitor-scripts/auto-maintain.sh.old /etc/monitor-scripts/auto-maintain.sh
cp /etc/monitor-scripts/helium-statuses.sh.old /etc/monitor-scripts/helium-statuses.sh
cp /etc/monitor-scripts/info-height.sh.old /etc/monitor-scripts/info-height.sh
cp /etc/monitor-scripts/miner.sh.old /etc/monitor-scripts/miner.sh
cp /etc/monitor-scripts/miner-update.sh.old /etc/monitor-scripts/miner-update.sh
cp /etc/monitor-scripts/miner-version-check.sh.old /etc/monitor-scripts/miner-version-check.sh
cp /etc/monitor-scripts/peer-list.sh.old /etc/monitor-scripts/peer-list.sh
cp /etc/monitor-scripts/pubkeys.sh.old /etc/monitor-scripts/pubkeys.sh
