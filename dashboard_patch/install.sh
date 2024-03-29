#!/bin/bash
# Make sure dashboard is installed
cd /etc/monitor-scripts
te=$?
if [ "$te" -eq 0 ]; then
  echo $(date -u) "Backing up existing scripts (if not already done)"
  # only backup files first time
  if [ ! -f "~admin/monitor-scripts.tar.bz2" ]; then
    tar cjf ~admin/monitor-scripts.tar.bz2 /etc/monitor-scripts/
    chown admin:admin ~admin/monitor-scripts.tar.bz2
  fi
  
  if [ ! -f "auto-maintain.sh.old" ]; then
    cp --preserve auto-maintain.sh auto-maintain.sh.old
  fi
  
  if [ ! -f "helium-statuses.sh.old" ]; then
    cp --preserve helium-statuses.sh helium-statuses.sh.old
  fi
  
  if [ ! -f "info-height.sh.old" ]; then
    cp --preserve info-height.sh info-height.sh.old
  fi
  
  if [ ! -f "miner.old" ]; then
    cp --preserve miner.sh miner.sh.old
  fi
  
  if [ ! -f "miner-update.old" ]; then
    cp --preserve miner-update.sh miner-update.sh.old
  fi
  
  if [ ! -f "miner-version-check.sh.old" ]; then
    cp --preserve miner-version-check.sh miner-version-check.sh.old
  fi
    
  if [ ! -f "peer-list.sh.old" ]; then
    cp --preserve peer-list.sh peer-list.sh.old
  fi
  
  if [ ! -f "pubkeys.sh.old" ]; then
    cp --preserve pubkeys.sh pubkeys.sh.old
  fi
  
  if [ ! -f "~admin/index.php.old" ]; then
    cp --preserve /var/dashboard/public/index.php ~admin/index.php.old
    sed -i 's/?tools.php=updateminer/index.php?page=updateminer/' /var/dashboard/public/index.php
  fi
  echo $(date -u) "Downloading patches"
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/dashboard.ini -O /etc/monitor-scripts/dashboard.ini
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/auto-maintain.sh -O /etc/monitor-scripts/auto-maintain.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/helium-statuses.sh -O /etc/monitor-scripts/helium-statuses.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/info-height.sh -O /etc/monitor-scripts/info-height.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/miner.sh -O /etc/monitor-scripts/miner.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/miner-update.sh -O /etc/monitor-scripts/miner-update.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/miner-version-check.sh -O /etc/monitor-scripts/miner-version-check.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/peer-list.sh -O /etc/monitor-scripts/peer-list.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/pubkeys.sh -O /etc/monitor-scripts/pubkeys.sh
  wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/refresh_dashboard/refresh-dash.sh -O /etc/monitor-scripts/refresh-dash.sh
  
  # set to executable
  chmod ugo+x /etc/monitor-scripts/auto-maintain.sh
  chmod ugo+x /etc/monitor-scripts/helium-statuses.sh
  chmod ugo+x /etc/monitor-scripts/info-height.sh
  chmod ugo+x /etc/monitor-scripts/miner.sh
  chmod ugo+x /etc/monitor-scripts/miner-update.sh
  chmod ugo+x /etc/monitor-scripts/miner-version-check.sh
  chmod ugo+x /etc/monitor-scripts/peer-list.sh
  chmod ugo+x /etc/monitor-scripts/pubkeys.sh
  chmod ugo+x /etc/monitor-scripts/refresh-dash.sh
  # Update the miner status
  echo $(date -u) "Refreshing cached dashboard status values"
  /etc/monitor-scripts/refresh-dash.sh
  # if docker miner is running, remove it
  echo $(date -u) "Checking if need to remove docker miner"
  docker=$(docker ps --format "{{.Image}}" --filter "name=miner")
  docker=$(echo $docker | grep -Po "miner-arm64")
  if [ "$docker" == "miner-arm64" ]; then
    docker stop miner
    docker rm miner
    echo $(date -u) " ... removed docker miner"
    else
    echo $(date -u) "... docker miner not found"
  fi

  echo $(date -u) 'Miner patched for helium_gateway. Check for miner updates now by looking at footer of this page.'
fi
