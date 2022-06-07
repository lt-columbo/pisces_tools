#!/bin/bash
echo "--------------------------------------------------------------------------"
echo " Installing power_monitor.sh script                                   "
echo "--------------------------------------------------------------------------"
cd /home/admin/
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/power_monitor/power_monitor.sh -O /home/admin/power_monitor.sh
chmod ugo+x /home/admin/power_monitor.sh
echo " app installed in: /home/admin/           "
echo " To run: type sudo ./power_monitor.php -f                                    "  
echo "--------------------------------------------------------------------------"
