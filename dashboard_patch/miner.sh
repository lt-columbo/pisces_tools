
#!/bin/bash
# Updated for Solana helium_gateway 1.0.0
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root - use sudo in front i.e. sudo ${0}" 
   exit 1
fi

source /etc/monitor-scripts/dashboard.ini
miner=(cat "$CFG_FN_ONLINE_STATUS")
if [ "$miner" == "active" ]; then
   echo 'true' > "$CFG_FN_MINER"
   else
   echo 'false' > "$CFG_FN_MINER"
fi
