#!/bin/bash
echo "--------------------------------------------------------------------------"
echo " Installing log_cpu_temp.php script                                       "
echo "--------------------------------------------------------------------------"
apt -y install php7.3-gd
cd /home/admin/
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/log_cpu_temp/log-cpu-temp.php -O /home/admin/log-cpu-temp.php
chmod ugo+x /home/admin/log-cpu-temp.php
if [! -d "/var/dashboard/public/includes" ] 
then
 mkdir /var/dashboard/public/includes
fi
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/log_cpu_temp/phplot.php -O /var/dashboard/public/includes/phplot.php
echo "*/15 * * * * /home/admin/log-cpu-temp.php"  >> /var/spool/cron/crontabs/root
systemctl restart cron.service
echo "app log-cpu-temp.php installed in: /home/admin/"
