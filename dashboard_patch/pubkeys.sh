#!/bin/bash
# Updated for Solana helium_gateway 1.0.0

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi

source /etc/monitor-scripts/dashboard.ini

name_pat='\"name\":\ \"([a-z]*-[a-z]*-[a-z]*)\"'
key_pat='\"key\":\ \"([A-Za-z0-9]*)\",'

data=$(/etc/helium_gateway/helium_gateway key info)

if [[ "$data" =~ $name_pat ]]; then
  match="${BASH_REMATCH[1]}" 
fi

echo "${match}" | tr '-' ' ' > "$CFG_FN_ANIMAL_NAME"
if [[ "$data" =~ $key_pat ]]; then
  match="${BASH_REMATCH[1]}"
fi
echo $match > "$CFG_FN_PUBKEY"
