#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo " Installing connected validator script.                                         "
echo "--------------------------------------------------------------------------------"
cd /home/admin/lora-packet-forwarder-analyzer
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/lorapacketforwarder/processlogslora.php -O /home/admin/lora-packet-forwarder-analyzer/processlogslora.php
chmod ugo+x /home/admin/lora-packet-forwarder-analyzer/processlogslora.php
echo "--------------------------------------------------------------------------------"
echo " To run: type ./processlogslora.php -f                                          "  
echo "--------------------------------------------------------------------------------"
