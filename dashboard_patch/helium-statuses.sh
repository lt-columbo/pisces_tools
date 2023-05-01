#!/bin/bash
# Updated for Solana helium_gateway 1.0.0

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi

source /etc/monitor-scripts/dashboard.ini

status_pat='\bActiveState=([A-Za-z]*)\b'
status_cmd='systemctl show helium'
pubkey=$(</var/dashboard/statuses/pubkey)
root_uri='https://api.helium.io/v1/hotspots/'
activity_uri="/activity"
uri="$root_uri$pubkey"
recent_activity_uri="$uri$activity_uri"

data=$(wget -qO- $uri)
recent_activity=$(curl -s $recent_activity_uri)

height=$(wget -qO- 'https://api.helium.io/v1/blocks/height' | grep -Po '"height":[^}]+' | sed -e 's/^"height"://')
lat=$(echo $data | grep -Po '"lat":[^\,]+' | sed -e 's/^"lat"://')
lng=$(echo $data | grep -Po '"lng":[^\,]+' | sed -e 's/^"lng"://')

miner_status=$(systemctl show ${CFG_HELIUM_SERVICE_NAME})
online_status="none"
if [[ $miner_status =~ $status_pat ]]; then
  online_status="${BASH_REMATCH[1]}"
fi

echo $online_status > ${CFG_FN_ONLINE_STATUS}

echo $lat > ${CFG_FN_LAT}
echo $lng > ${CFG_FN_LNG}
echo $height > ${CFG_FN_CUR_BLKHGT}
echo $recent_activity > ${CFG_FN_RECENT_ACTIVITY}

if [ -f "/etc/monitor-scripts/dash-hook.sh" ]; then
   /etc/monitor-scripts/dashboard-hook.sh
fi
