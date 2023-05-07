#!/bin/bash

function nextsuffix {
  local name="$1.bak"
  if [ -e "$name" ]; then
    printf "%s" "$name"
  else
    local -i num=1
    while [ -e "$name.$num" ]; do
      num+=1
    done
    printf "%s%d" "$name." "$num"
  fi
}

# Updated for Solana helium_gateway 1.0.0
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root - use sudo in front i.e. sudo ${0}"
  exit 1
fi

source /etc/monitor-scripts/dashboard.ini
service=$(cat $CFG_FN_MINER_UPDATE | tr -d '\n')
version=$(cat $CFG_FN_LATEST_MINER_VER | tr -d '\n')

if [ "$service" == 'start' ]; then
  echo 'running' >"$CFG_FN_MINER_UPDATE"
  echo $(date "$CFG_TIME_FORMAT_LOG") "Starting update processing for $CFG_FN_HELIUM_GATEWAY ..." >"$CFG_FN_MINER_UPDATE_LOG"
  helium_filename=${CFG_FN_GATEWAY_HEAD}${version}${CFG_FN_GATEWAY_TAIL}
  echo $(date "$CFG_TIME_FORMAT_LOG") "Pulling latest firmware from ${CFG_GITHUB_MINER_URL}$version" >>"$CFG_FN_MINER_UPDATE_LOG"
  echo $(date "$CFG_TIME_FORMAT_LOG") "Filename requested is $helium_filename" >>"$CFG_FN_MINER_UPDATE_LOG"
  url="${CFG_GITHUB_MINER_URL}$version"
  url+='/'"${helium_filename}"
  #echo $(date "$CFG_TIME_FORMAT_LOG") "Full url is $url" >> "$CFG_FN_MINER_UPDATE_LOG"
  wget "$url" -P "$CFG_WORK_DIR" >>"$CFG_FN_MINER_UPDATE_LOG"
  te=$?
  # If pulled firmware into work dir keep going
  if [ "$te" -eq 0 ]; then
    echo $(date "$CFG_TIME_FORMAT_LOG") "Extracting $CFG_FN_HELIUM_GATEWAY into $CFG_WORK_DIR " >>"$CFG_FN_MINER_UPDATE_LOG"
    tar -xvf "${CFG_WORK_DIR}$helium_filename" -C "$CFG_WORK_DIR"
    te=$?
    # If extracted firmware keep going
    if [ "$te" -eq 0 ]; then

      if [ "$CFG_PROCESS_SETTINGS_FILE" -eq '1' ]; then
        # Use sed to edit the settings files n work_settings file to change
        # from file keypair Pisces ecc settings
        # We want to end up with something like this:
        # #File based:
        # #keypair = "/etc/helium_gateway/gateway_key.bin"
        # #onboarding = "ecc://i2c-1:96?slot=15"
        # keypair = "ecc://i2c-0:96?slot=0"
        # onboarding = "ecc://i2c-0:96?slot=15"
        settings_chg_ok=1
        work_settings="${CFG_WORK_DIR}${CFG_FN_HELIUM_GATEWAY_SETTINGS}"
        echo $(date "$CFG_TIME_FORMAT_LOG") "Attempting to customize the settings file $work_settings" >>"$CFG_FN_MINER_UPDATE_LOG"
        sed -i "s@${CFG_FIND_KEYFILE}@${CFG_REPLACEMENT_KEYFILE}@" "$work_settings"
        if [ "$?" -ne 0 ]; then
          settings_chg_ok=0
        fi
        # leading \ needed for delimiter at pos 0 to sed on a=append, otherwise ack
        sed -i "\@$CFG_FIND_ECC_KEYPAIR@ a $CFG_ADD_ECC_KEYPAIR1" "$work_settings"
        if [ "$?" -ne 0 ]; then
          settings_chg_ok=0
        fi
        # leading \ needed for delimiter at pos 0 to sed on a=append, otherwise ack
        sed -i "\@$CFG_ADD_ECC_KEYPAIR1@ a $CFG_ADD_ECC_KEYPAIR2" "$work_settings"
        if [ "$?" -ne 0 ]; then
          settings_chg_ok=0
        fi
        # double check changes made
        echo $(date "$CFG_TIME_FORMAT_LOG") "Verifying customization to $work_settings" >>"$CFG_FN_MINER_UPDATE_LOG"
        if ! grep -Fxq "$CFG_REPLACEMENT_KEYFILE" "$work_settings"; then
          settings_chg_ok=0
        fi
        if ! grep -Fxq "$CFG_ADD_ECC_KEYPAIR2" "$work_settings"; then
          settings_chg_ok=0
        fi
        if ! grep -Fxq "$CFG_ADD_ECC_KEYPAIR2" "$work_settings"; then
          settings_chg_ok=0
        fi
        if [ $settings_chg_ok -eq 1 ]; then
          settings="${CFG_DIR_HELIUM_GATEWAY_HOME}${CFG_FN_HELIUM_GATEWAY_SETTINGS}"
          settings_bu=$CFG_FN_HELIUM_GATEWAY_SETTINGS_BU
          if [ ! -d "$settings_bu" ]; then
            mkdir "$settings_bu"
          fi
          settings_bu+="$CFG_FN_HELIUM_GATEWAY_SETTINGS"
          backup_fn=$(nextsuffix "$settings_bu")
          cp "$settings" "$backup_fn"
          cp "$work_settings" "$settings"
          echo $(date "$CFG_TIME_FORMAT_LOG") "Success. Old settings file backed up to $backup_fn" >>"$CFG_FN_MINER_UPDATE_LOG"
          echo "Restore old settings with sudo cp $backup_fn ${CFG_DIR_HELIUM_GATEWAY_HOME}${CFG_FN_HELIUM_GATEWAY_SETTINGS}" >>"$CFG_FN_MINER_UPDATE_LOG"
        else
          echo $(date "$CFG_TIME_FORMAT_LOG") "FAILED.  Customization of settings **FAILED** leaving existing settings" >>"$CFG_FN_MINER_UPDATE_LOG"
        fi
      fi

      echo $(date "$CFG_TIME_FORMAT_LOG") "Installing the updated miner to $CFG_DIR_HELIUM_GATEWAY_HOME" >>"$CFG_FN_MINER_UPDATE_LOG"
      mv ${CFG_WORK_DIR}${CFG_FN_HELIUM_GATEWAY} "$CFG_DIR_HELIUM_GATEWAY_HOME"

      # Delete the gz file
      echo $(date "$CFG_TIME_FORMAT_LOG") 'Cleaning up, Removing downloaded firmware.' >>"$CFG_FN_MINER_UPDATE_LOG"

      rm "${CFG_WORK_DIR}${helium_filename}"

      echo $(date "$CFG_TIME_FORMAT_LOG") "Checking if docker miner is installed" >>"$CFG_FN_MINER_UPDATE_LOG"
      docker=$(docker ps --format "{{.Image}}" --filter "name=miner")
      docker=$(echo $docker | grep -Po "miner-arm64")
      if [ "$docker" = "miner-arm64" ]; then
        docker stop miner
        docker rm miner
        echo $(date "$CFG_TIME_FORMAT_LOG") "Docker miner was found and removed" >>"$CFG_FN_MINER_UPDATE_LOG"
      else
        echo $(date "$CFG_TIME_FORMAT_LOG") "Docker miner was not found" >>"$CFG_FN_MINER_UPDATE_LOG"
      fi

      # Stop the service of helium
      echo $(date "$CFG_TIME_FORMAT_LOG") "Stopping/Restarting $CFG_HELIUM_SERVICE_NAME service" >>"$CFG_FN_MINER_UPDATE_LOG"
      service "$CFG_HELIUM_SERVICE_NAME" stop >>"$CFG_FN_MINER_UPDATE_LOG"

      # Start up the service
      service "$CFG_HELIUM_SERVICE_NAME" start >>"$CFG_FN_MINER_UPDATE_LOG"

      echo $(date "$CFG_TIME_FORMAT_LOG") "Update to $version complete." >>"$CFG_FN_MINER_UPDATE_LOG"
      # Update the lsb_release file
      echo "$version" >/etc/lsb_release
      /etc/monitor-scripts/miner-version-check.sh
      if [ "$settings_chg_ok" -eq 0 ]; then
        echo $(date "$CFG_TIME_FORMAT_LOG") "WARNING: Settings file was NOT Updated, using from prior release" >>"$CFG_FN_MINER_UPDATE_LOG"
      fi
      echo $(date "$CFG_TIME_FORMAT_LOG") 'Visit home page to see new version on footer' >>"$CFG_FN_MINER_UPDATE_LOG"
    fi
  else
    echo $(date "$CFG_TIME_FORMAT_LOG") "New firmware not found on Github" >>"$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "Complete url: $url" >>"$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "Firmware file expected: $helium_firmware" >>"$CFG_FN_MINER_UPDATE_LOG"
  fi
fi
echo 'stopped' >"$CFG_FN_MINER_UPDATE"
