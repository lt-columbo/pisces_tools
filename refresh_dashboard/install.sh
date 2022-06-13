#!/bin/bash
echo "--------------------------------------------------------------------------"
echo " Installing refresh_dash.sh script                                   "
echo "--------------------------------------------------------------------------"
cd /home/admin/
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/refresh_dashboard/refresh-dash.sh -O /home/admin/refresh-dash.sh
chmod ugo+x /home/admin/refresh-dash.sh
echo " app installed in: /home/admin/           "
echo " To run: type sudo ./refresh-dash.sh                                      "  
