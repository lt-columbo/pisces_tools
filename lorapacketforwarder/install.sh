#!/bin/bash
echo "--------------------------------------------------------------------------"
echo " Installing connected validator script.                                   "
echo "--------------------------------------------------------------------------"
if [! -d "/path/to/dir" ] 
then
cd /home/admin/lora-packet-forwarder-analyzer
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/lorapacketforwarder/processlogslora.php -O /home/admin/lora-packet-forwarder-analyzer/processlogslora.php
chmod ugo+x /home/admin/lora-packet-forwarder-analyzer/processlogslora.php
echo "--------------------------------------------------------------------------"
echo " app installed in: /home/admin/lora-packet-forwarder-analyzer/            "
echo " To run: type ./processlogslora.php -f                                    "  
echo "--------------------------------------------------------------------------"
else 
echo "--------------------------------------------------------------------------"
echo " FAILURE. The app failed to install because:                      "
echo " You must first install the inigoflores lora-packet-analyzer      "
echo " see https://github.com/inigoflores/lora-packet-forwarder-analyzer"
echo "--------------------------------------------------------------------------"
fi
