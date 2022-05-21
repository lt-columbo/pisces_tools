#!/bin/bash
filename='version.patch.txt'
echo "---------------------------------------------------------------------------------"
echo " This patch only updates the version number and not the actual dashboard version "
echo "---------------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_version_update/$filename -O /tmp/$filename
if [ ! -f "/tmp/$filename" ]; then
    echo "$filename does not exist. 1) Check permissions. 2) Run as sudo"
    exit 2
fi

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
    echo "Version number patch complete."
    echo "The prior version data is in the file /var/dashboard/version.last"
    echo "To restore the original version, run this command:"
    echo "sudo cp /var/dashboard/version.last /var/dashboard/version"
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
