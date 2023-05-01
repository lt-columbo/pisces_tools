#!/bin/bash
# Requires sudo
# Refresh all cached values in use by dashboard
# ---
# pubkey used by helium-statuses.sh so do before it
# ---
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
# /etc/monitor-scripts/info-height.sh
# Internal IP Address
echo "Internal IP Address"
/etc/monitor-scripts/local-ip.sh
# Miner Status
echo "Miner Status"
/etc/monitor-scripts/miner.sh
# miner version and latest version
echo "Miner version, latest version available"
/etc/monitor-scripts/miner-version-check.sh

# Serial Number
echo "Serial Number"
/etc/monitor-scripts/sn-check.sh
# CPU Temp
echo "CPU Temp"
/etc/monitor-scripts/temp.sh
echo "Done. Dashboard values refreshed"
