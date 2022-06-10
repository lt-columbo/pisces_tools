#!/bin/bash
# Requires sudo
# Refresh all cached values in used by by dashboard
# ---
# pubkey used by helium-statuses.sh so do before it
# ---
/etc/monitor_scripts/pubkeys.sh
/etc/monitor_scripts/external-ip.sh
/etc/monitor_scripts/helium-statuses.sh 
# info_height run by helium-statuses.sh
# /etc/monitor_scripts/info-height.sh
/etc/monitor_scripts/local-ip.sh
/etc/monitor_scripts/miner.sh
/etc/monitor_scripts/miner-version-check.sh
/etc/monitor_scripts/peer-list.sh
/etc/monitor_scripts/sn-check.sh
/etc/monitor_scripts/temp.sh
