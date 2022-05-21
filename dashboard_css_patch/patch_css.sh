#!/bin/bash
filename="css.patch.txt"
dir="/var/dashboard/public/css"
echo "--------------------------------------------------------------------------------"
echo " This patch increases the width of dashboard for use with widescreen computers  "
echo "--------------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_css_patch/$filename -O /tmp/$filename
if [ ! -f "/tmp/$filename" ]; then
    echo "$filename does not exist. 1) Check permissions. 2) Run as sudo"
    exit 1
fi

cd $dir
if [ "$PWD" = "$dir" ]; then
  cp common.css common.css.orig
  patch < /tmp/$filename
  if [ "$?" = "0" ]; then
    echo "css update SUCCESSFUL. Press Ctrl-F5/Cmd-F5 in browser to reload the css for changes to take effect."
    rm /tmp/$filename
    else
    echo "patch FAILED, css left unchanged. Perhaps already applied?"
    rm /tmp/$filename
    exit 2
  fi
  else
  echo "Patch FAILED. Could not change directory to $dir"
  rm /tmp/$filename
  exit 3
fi
