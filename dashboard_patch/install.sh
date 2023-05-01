#!/bin/bash
cd /etc/monitor-scripts
te=$?
if [ "$te" -eq 0 ]; then
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/dashboard.ini
  # only backup files first time
  if [ ! -f "~admin/monitor-scripts.tar.bz2" ]; then
    tar cjf ~admin/monitor-scripts.tar.bz2 helium-statuses.sh info-height.sh miner-update.sh miner-version-check.sh pubkeys.sh
    chown admin:admin ~admin/monitor-scripts.tar.bz2
  fi
  
  if [ ! -f "helium-statuses.sh.old" ]; then
    cp --preserve helium-statuses.sh helium-statuses.sh.old
  fi
  
  if [ ! -f "info-height.sh.old" ]; then
    cp --preserve info-height.sh info-height.sh.old
  fi
  
  if [ ! -f "miner-update.old" ]; then
    cp --preserve miner-update.sh miner-update.sh.old
  fi
  
  if [ ! -f "miner-version-check.sh.old" ]; then
    cp --preserve miner-version-check.sh miner-version-check.sh.old
  fi
  
  if [ ! -f "pubkeys.sh.old" ]; then
    cp --preserve pubkeys.sh pubkeys.sh.old
  fi  
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/helium-statuses.sh -O /etc/monitor-scripts/helium-statuses.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/info-height.sh -O /etc/monitor-scripts/info-height.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/miner-update.sh -O /etc/monitor-scripts/miner-update.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/miner-version-check.sh -O /etc/monitor-scripts/miner-version-check.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/pubkeys.sh -O /etc/monitor-scripts/pubkeys.sh
fi