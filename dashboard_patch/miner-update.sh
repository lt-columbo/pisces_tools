#!/bin/bash
# Updated for Solana helium_gateway 1.0.0
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi
source /etc/monitor-scripts/dashboard.ini
service=$(cat ${CFG_FN_MINER_UPDATE} | tr -d '\n')
version=$(cat ${CFG_FN_LATEST_MINER_VER} | tr -d '\n')


if [[ ${service} == 'start' ]]; then
  echo -n > ${CFG_FN_MINER_UPDATE_LOG}	
  echo 'running' > ${CFG_FN_MINER_UPDATE}
  echo $(date -u) "Starting update processing for ${CFG_FN_HELIUM_GATEWAY} ..." > ${CFG_FN_MINER_UPDATE_LOG}
   
  echo $(date -u) 'Acquiring and starting latest miner version...' >> ${CFG_FN_MINER_UPDATE_LOG}
  helium_filename=${CFG_FN_GATEWAY_HEAD}${version}${CFG_FN_GATEWAY_TAIL}
  echo $(date -u) "Pulling latest firmware from ${CFG_GITHUB_MINER_URL}$version" >> ${CFG_FN_MINER_UPDATE_LOG}
  echo $(date -u) "Filename requested is $helium_filename" >> ${CFG_FN_MINER_UPDATE_LOG}
  url=${CFG_GITHUB_MINER_URL}$version
  url+='/'${helium_filename}
  #echo $(date -u) "Full url is ${url}" >> ${CFG_FN_MINER_UPDATE_LOG}
  wget "$url" -P /tmp >> ${CFG_FN_MINER_UPDATE_LOG} 
  te=$?
  if [ "$te" -eq 0 ]; then
    echo $(date -u) "Extracting ${CFG_HELIUM_GATEWAY} into /tmp" >> ${CFG_FN_MINER_UPDATE_LOG}
    tar -xvf "/tmp/$helium_filename" -C "/tmp" ${CFG_FN_HELIUM_GATEWAY} 
    te=$?
    if [ "$te" -eq 0 ]; then  
      echo $(date -u) "Extract complete moving to ${CFG_DIR_HELIUM_GATEWAY_HOME}" >> ${CFG_FN_MINER_UPDATE_LOG}
      mv /tmp/${CFG_FN_HELIUM_GATEWAY} "${CFG_DIR_HELIUM_GATEWAY_HOME}"
   
      # Delete the gz file 
      echo $(date -u) 'Removing downloaded archive of new firmware.'  >> ${CFG_FN_MINER_UPDATE_LOG}
      rm "/tmp/${helium_filename}"

      echo $(date -u) "Checking if need to remove docker miner"  >> ${CFG_FN_MINER_UPDATE_LOG}
      docker = $(docker ps --format "{{.Image}}" --filter "name=miner" | grep -Po "miner-arm64")
      if [ "${docker}" -eq "miner-arm64"} ]; then
        docker stop miner  
        docker rm miner
        echo $(date -u) "Removed docker miner"  >> ${CFG_FN_MINER_UPDATE_LOG}
      }
      # Stop the service of helium
      echo $(date -u) "Stopping/Restarting ${CFG_HELIUM_SERVICE_NAME} service"  >> ${CFG_FN_MINER_UPDATE_LOG}
      service ${CFG_HELIUM_SERVICE_NAME} stop >> ${CFG_FN_MINER_UPDATE_LOG} 

      # Start up the service
      service ${CFG_HELIUM_SERVICE_NAME} start >> ${CFG_FN_MINER_UPDATE_LOG}

      echo $(date -u) "Update to ${version} complete." >> ${CFG_FN_MINER_UPDATE_LOG}
      # Update the lsb_release file
      echo ${version} > /etc/lsb_release
      /etc/monitor-scripts/miner-version-check.sh
      echo $(date -u) 'Visit home page to see new version on footer' >> ${CFG_FN_MINER_UPDATE_LOG}
    fi
    else
      echo "New firmware not found on Github"
   fi
fi
echo 'stopped' > ${CFG_FN_MINER_UPDATE}
