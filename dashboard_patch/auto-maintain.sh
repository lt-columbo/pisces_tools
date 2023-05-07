#!/bin/bash
# Updated for Solana helium_gateway 1.0.0

source /etc/monitor-scripts/dashboard.ini

service=$(cat ${CFG_FN_AUTO_MAINTAIN} | tr -d '\n')

if [ "$service" == 'enabled' ]; then
  bash /etc/monitor-scripts/update-check.sh &> /dev/null
  bash /etc/monitor-scripts/miner-version-check.sh &> /dev/null
  bash /etc/monitor-scripts/helium-statuses.sh &> /dev/null
  online_status=$(cat ${CFG_FN_ONLINE_STATUS})

  if [[ ! "$online_status" =~ 'active' ]]; then
    echo "[$(date)] Problems with ${CFG_FN_HELIUM_GATEWAY}..." >> ${CFG_FN_AUTO_MAINTAIN_LOG}
    systemctl restart "${CFG_FN_HELIUM_GATEWAY}"
    sleep 1m
    bash /etc/monitor-scripts/helium-statuses.sh &> /dev/null
    online_status=$(cat ${CFG_FN_ONLINE_STATUS})
  fi

  if [[ ! "$pubkey" ]]; then
    echo "[$(date)] Your public key is missing, trying a refresh..." >> ${CFG_FN_AUTO_MAINTAIN_LOG}
    bash /etc/monitor-scripts/pubkeys.sh
  fi
  
fi
