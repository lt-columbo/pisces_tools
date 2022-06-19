#!/bin/bash
echo "--------------------------------------------------------------------------"
echo " Installing log_cpu_temp.php script                                       "
echo "--------------------------------------------------------------------------"
apt -y install php7.3-gd
cd /home/admin/
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/log_cpu_temp/log-cpu-temp.php -O /home/admin/log-cpu-temp.php
chmod ugo+x /home/admin/log-cpu-temp.php
# install phplot in new directory in /var/dashboard
if [! -d "/var/dashboard/public/includes" ] 
then
 mkdir /var/dashboard/public/includes
fi
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/log_cpu_temp/phplot.php -O /var/dashboard/public/includes/phplot.php
# install cpu_temp.php page in dashboard at /var/dashboard/pages/cpu_temp.php
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/log_cpu_temp/cpu_temp.php -O /var/dashboard/pages/cpu_temp.php
# install cron job to run logger every 15 minutes
echo "*/15 * * * * /home/admin/log_cpu_temp.php"  >> /var/spool/cron/crontabs/root
systemctl restart cron.service
touch /var/dashboard/logs/cpu-temp.log
touch /var/dashboard/logs/cpu-temp-history.log
echo "app log-cpu-temp.php installed in: /home/admin/"
