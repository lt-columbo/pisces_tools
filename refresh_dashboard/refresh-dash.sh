#!/bin/bash
# Requires sudo
# Refresh all cached values in used by by dashboard
# ---
# pubkey used by helium-statuses.sh so do before it
# ---
# Animal name
/etc/monitor_scripts/pubkeys.sh
#External Facing IP Address
/etc/monitor_scripts/external-ip.sh
# Blockchain Height, Miner Height, Miner Status, lat, long, recent activity
/etc/monitor_scripts/helium-statuses.sh 
# info_height run by helium-statuses.sh (local height)
# /etc/monitor_scripts/info-height.sh
# Internal IP Address
/etc/monitor_scripts/local-ip.sh
# Miner Status
/etc/monitor_scripts/miner.sh
# miner version and latest version
/etc/monitor_scripts/miner-version-check.sh
# Peer list at bottom of home page
/etc/monitor_scripts/peer-list.sh
# Serial Number
/etc/monitor_scripts/sn-check.sh
# CPU Temp
/etc/monitor_scripts/temp.sh
