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
result=0

if [ "$service" == 'start' ]; then
  settings="${CFG_DIR_HELIUM_GATEWAY_HOME}${CFG_FN_HELIUM_GATEWAY_SETTINGS}"
  echo 'running' >"$CFG_FN_MINER_UPDATE"
  current_version=$(cat $CFG_FN_CURRENT_MINER_VER)
  echo $(date "$CFG_TIME_FORMAT_LOG") "Starting update for $CFG_FN_HELIUM_GATEWAY ... current version is $current_version" > "$CFG_FN_MINER_UPDATE_LOG"
  date_now=$(date "$CFG_TIME_FORMAT_LOG")
  printf '%s' "$date_now Checking if $CFG_FN_HELIUM_GATEWAY is installed" >> "$CFG_FN_MINER_UPDATE_LOG"
  if [ ! -f $settings ]; then
    echo ' ... No' >> "$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "Miner Update did not find an installed $CFG_FN_HELIUM_GATEWAY miner settings file" >> "$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "Install miner using Pisces update.sh script (see below)" >>"$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "sudo wget http://pisces-firmware.sidcloud.cn/latest/??/update.sh -O - | sudo bash" >> "$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "CHANGE region (the ??) in above URL to your region such as one of CN, EU or US" >> "$CFG_FN_MINER_UPDATE_LOG"
    echo $(date "$CFG_TIME_FORMAT_LOG") "Update FAILED" >>"$CFG_FN_MINER_UPDATE_LOG"
    # return code 1 - settings not found
    result=1
  else
    echo ' ... Yes' >> "$CFG_FN_MINER_UPDATE_LOG"
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
          # Replace the region code in new settings with one from the in place settings file
          region_data=$(grep -Pio "$CFG_FIND_REGION_RE" "$settings")
          region_data_new=$(grep -Pio "$CFG_FIND_REGION_RE" "$work_settings")
          echo $(date "$CFG_TIME_FORMAT_LOG") "Region in current settings is: $region_data" >>"$CFG_FN_MINER_UPDATE_LOG"
          # Replace region setting in new settings with one from existing
          sed -i "s@${region_data_new}@${region_data}@" "$work_settings"
          # Comment out the keyfile line
          sed -i "s@${CFG_FIND_KEYFILE}@${CFG_REPLACEMENT_KEYFILE}@" "$work_settings"
          if [ "$?" -ne 0 ]; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: Replacement of '$region_data_new' with '$region_data' failed" >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
          # insert keypair line after set on keypair/onboarding in new settings file
          # leading \ needed for delimiter other than / at pos 0 to sed on a=append, otherwise ack
          sed -i "\@$CFG_FIND_ECC_KEYPAIR@ a $CFG_ADD_ECC_KEYPAIR1" "$work_settings"
          if [ "$?" -ne 0 ]; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: Adding line '$CFG_ADD_ECC_KEYPAIR1' failed" >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
          # insert onboarding line after keypair just inserted
          # leading \ needed for delimiter other than / at pos 0 to sed on a=append, otherwise ack
          sed -i "\@$CFG_ADD_ECC_KEYPAIR1@ a $CFG_ADD_ECC_KEYPAIR2" "$work_settings"
          if [ "$?" -ne 0 ]; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: Adding line '$CFG_ADD_ECC_KEYPAIR2' failed" >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
          # double check changes made
          echo $(date "$CFG_TIME_FORMAT_LOG") "Verifying customization to $work_settings" >>"$CFG_FN_MINER_UPDATE_LOG"
          # Test for: Region="EU868"|"US915" etc
          if ! grep -Fxq "$region_data" "$work_settings"; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: '$region_data' not in new settings file " >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
          # Test for: Comment out #keyfile line
          if ! grep -Fxq "$CFG_REPLACEMENT_KEYFILE" "$work_settings"; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: '$CFG_REPLACEMENT_KEYFILE' not in new settings file " >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
          # Test for: Pisces keypair ecc line
          if ! grep -Fxq "$CFG_ADD_ECC_KEYPAIR2" "$work_settings"; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: '$CFG_ADD_ECC_KEYPAIR2' not in new settings file " >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
          # Test for: Pisces onboarding ecc line
          if ! grep -Fxq "$CFG_ADD_ECC_KEYPAIR2" "$work_settings"; then
            settings_chg_ok=0
            echo $(date "$CFG_TIME_FORMAT_LOG") "ERROR: '$CFG_ADD_ECC_KEYPAIR2' not in new settings file " >>"$CFG_FN_MINER_UPDATE_LOG"
          fi

          if [ $settings_chg_ok -eq 1 ]; then
            settings_bu=$CFG_FN_HELIUM_GATEWAY_SETTINGS_BU
            if [ ! -d "$settings_bu" ]; then
              mkdir "$settings_bu"
            fi
            settings_bu+="$CFG_FN_HELIUM_GATEWAY_SETTINGS"
            backup_fn=$(nextsuffix "$settings_bu")
            cp "$settings" "$backup_fn"
            mv "$work_settings" "$settings"
            echo $(date "$CFG_TIME_FORMAT_LOG") "Success. Old settings file backed up to $backup_fn" >>"$CFG_FN_MINER_UPDATE_LOG"
            #echo $(date "$CFG_TIME_FORMAT_LOG") "Restore old settings with sudo cp $backup_fn ${CFG_DIR_HELIUM_GATEWAY_HOME}${CFG_FN_HELIUM_GATEWAY_SETTINGS}" >>"$CFG_FN_MINER_UPDATE_LOG"
          else
            echo $(date "$CFG_TIME_FORMAT_LOG") "FAILED.  Customization of settings **FAILED** leaving existing settings" >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
        fi

        echo $(date "$CFG_TIME_FORMAT_LOG") "Installing the updated miner to $CFG_DIR_HELIUM_GATEWAY_HOME" >>"$CFG_FN_MINER_UPDATE_LOG"
        mv ${CFG_WORK_DIR}${CFG_FN_HELIUM_GATEWAY} "$CFG_DIR_HELIUM_GATEWAY_HOME"

        # Delete the gz file
        echo $(date "$CFG_TIME_FORMAT_LOG") 'Cleaning up, Removing downloaded firmware.' >>"$CFG_FN_MINER_UPDATE_LOG"

        rm "${CFG_WORK_DIR}${helium_filename}"

        if [ "$CFG_CHECK_REMOVE_DOCKER" -eq '1' ]; then
          date_now=$(date "$CFG_TIME_FORMAT_LOG")
          printf '%s' "$date_now Checking if docker miner is installed" >> "$CFG_FN_MINER_UPDATE_LOG"
          docker=$(docker ps --format "{{.Image}}" --filter "name=miner")
          docker=$(echo $docker | grep -Po "miner-arm64")
          if [ "$docker" = "miner-arm64" ]; then
            docker stop miner
            docker rm miner
            echo " ... Yes" >>"$CFG_FN_MINER_UPDATE_LOG"
            echo $(date "$CFG_TIME_FORMAT_LOG") "Docker miner was found and removed" >>"$CFG_FN_MINER_UPDATE_LOG"
          else
            echo " ... No" >>"$CFG_FN_MINER_UPDATE_LOG"
          fi
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
        else
          echo $(date "$CFG_TIME_FORMAT_LOG") "Extract of new firmware failed" >>"$CFG_FN_MINER_UPDATE_LOG"
          echo $(date "$CFG_TIME_FORMAT_LOG") "Update FAILED" >>"$CFG_FN_MINER_UPDATE_LOG"
          result=3
      fi
    else
      echo $(date "$CFG_TIME_FORMAT_LOG") "New firmware not found on Github" >>"$CFG_FN_MINER_UPDATE_LOG"
      echo $(date "$CFG_TIME_FORMAT_LOG") "Complete url: $url" >>"$CFG_FN_MINER_UPDATE_LOG"
      echo $(date "$CFG_TIME_FORMAT_LOG") "Firmware file expected: $helium_firmware" >>"$CFG_FN_MINER_UPDATE_LOG"
      echo $(date "$CFG_TIME_FORMAT_LOG") "Update FAILED" >>"$CFG_FN_MINER_UPDATE_LOG"
      result=2
    fi
  fi
fi
echo 'stopped' >"$CFG_FN_MINER_UPDATE"
exit $result
