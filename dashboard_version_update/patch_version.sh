#!/bin/bash
filename='version.patch.txt'
pattern="https://quay.io/api/v1/repository/team-helium/miner "
file_to_test="/etc/monitor-scripts/miner-version-check.sh"
echo "---------------------------------------------------------------------------------"
echo " This patch only updates the version number and not the actual dashboard version "
echo "---------------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_version_update/$filename -O /tmp/$filename
if [ ! -f "/tmp/$filename" ]; then
    echo "$filename does not exist. 1) Check permissions. 2) Run as sudo"
    exit 2
fi
# compare against last change to dashboard
match=$(grep $pattern $file_to_test)
if [ -z "$match" ]; then
    echo "It doesn't appear that dashboard is on version 0.2.8"
    echo $match
    exit 5
fi
# change to dashboard, make sure we're there
cd /var/dashboard
if [ "$PWD" = "/var/dashboard" ]; then
  cp version version.last
  cur_version=$(cat version)
  echo "Current Version $cur_version Output of patch command below:"
  patch < /tmp/$filename
  if [ "$?" = "0" ]; then
    echo "Version Updated"
    new_version=$(cat version)
    echo "New Version $new_version"
    echo ""
    echo "Version number patch completed successfully."
    rm /tmp/$filename
    else
    echo "patch FAILED, Dashboard Version Number left unchanged. Perhaps already applied?"
    rm /tmp/$filename
    exit 3
  fi
  else
  echo "Patch Failed. Could not change directory to /var/dashboard"
  rm /tmp/$filename
  exit 4
fi
