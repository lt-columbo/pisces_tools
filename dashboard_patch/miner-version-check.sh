#!/bin/bash
# Updated for Solana helium_gateway 1.0.0

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi

source /etc/monitor-scripts/dashboard.ini

grep_version_pat='https://github.com/helium/gateway-rs/releases/expanded_assets/v[0-9]+\.[0-9]+\.[0-9]+'
version_pat='([0-9]+\.[0-9]+\.[0-9]+)'

latest='unknown'
version_assets=$(curl -s ${CFG_GITHUB_MINER_REPO} | grep -Po ${grep_version_pat})
if [[ $version_assets =~ ${version_pat} ]]; then
  latest=${BASH_REMATCH[1]}
fi  
echo ${latest} > ${CFG_FN_LATEST_MINER_VER}

current="unknown"
helium_cmd=${CFG_DIR_HELIUM_GATEWAY_HOME}${CFG_FN_HELIUM_GATEWAY}
helium_current=$(${helium_cmd} --version)
if [[ ${helium_current} =~ ${version_pat} ]]; then
  current=${BASH_REMATCH[1]}
fi
echo $current > ${CFG_FN_CURRENT_MINER_VER}
