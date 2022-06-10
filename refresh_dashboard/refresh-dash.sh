#!/bin/bash
# Requires sudo
# Refresh all cached values in used by by dashboard
# ---
# pubkey used by helium-statuses.sh so do before it
# ---
# Animal name
/etc/monitor-scripts/pubkeys.sh
#External Facing IP Address
/etc/monitor-scripts/external-ip.sh
# Blockchain Height, Miner Height, Miner Status, lat, long, recent activity
/etc/monitor-scripts/helium-statuses.sh
# info_height run by helium-statuses.sh (local height)
# /etc/monitor-scripts/info-height.sh
# Internal IP Address
/etc/monitor-scripts/local-ip.sh
# Miner Status
/etc/monitor-scripts/miner.sh
# miner version and latest version
/etc/monitor-scripts/miner-version-check.sh
# Peer list at bottom of home page
/etc/monitor-scripts/peer-list.sh
# Serial Number
/etc/monitor-scripts/sn-check.sh
# CPU Temp
/etc/monitor-scripts/temp.sh
