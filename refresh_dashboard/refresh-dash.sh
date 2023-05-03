#!/bin/bash
# Requires sudo
# Refresh all cached values in use by dashboard
# ---
# pubkey used by helium-statuses.sh so do before it
# ---
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi

source /etc/monitor-scripts/dashboard.ini

# Animal name
echo "Refreshing Pub keys, animal name"
/etc/monitor-scripts/pubkeys.sh
#External Facing IP Address
echo "External IP"
/etc/monitor-scripts/external-ip.sh  >/dev/null 2>/dev/null
# Blockchain Height, Miner Height, Miner Status, lat, long, recent activity
echo "Blockchain height, Miner height ..."
/etc/monitor-scripts/helium-statuses.sh  >/dev/null 2>/dev/null
# info_height run by helium-statuses.sh (local height)
/etc/monitor-scripts/info-height.sh
# Internal IP Address
echo "Internal IP Address"
/etc/monitor-scripts/local-ip.sh
# Miner Status
echo "Miner Status"
miner=(cat ${CFG_FN_ONLINE_STATUS})
if [ "$miner" == "active" ]; then
   echo 'true' > ${CFG_FN_MINER}
   else
   echo 'false' > ${CFG_FN_MINER}
fi
# miner version and latest version
echo "Miner version, latest version available"
/etc/monitor-scripts/miner-version-check.sh
# Peer list at bottom of home page
echo "Peer list"
/etc/monitor-scripts/peer-list.sh
# Serial Number
echo "Serial Number"
/etc/monitor-scripts/sn-check.sh
# CPU Temp
echo "CPU Temp"
/etc/monitor-scripts/temp.sh
echo "Done. Dashboard values refreshed"
