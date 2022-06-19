#!/bin/bash
echo "--------------------------------------------------------------------------"
echo " Removing log_cpu_temp.php script                                         "
echo "--------------------------------------------------------------------------"
# remove gd
apt remove -y php7.3-gd
# remove logger cron job
sed -i '/log-cpu-temp/d' /var/spool/cron/root
systemctl restart cron.service
# remove cpu temp logger
cd /home/admin/
rm /home/admin/log_cpu_temp.php
# remove php plot and the includes directory
rm /var/dashboard/public/includes/phplot.php
# make sure includes directory is empty before removing it
if [ -z "$(ls -A /var/dashboard/public/includes)" ]; then
  rm -rf /var/dashboard/public/includes
fi
# remove dashboard page for graph
rm /var/dashboard/pages/cpu_temp.php
echo "app log-cpu-temp.php removed"
echo "NOTE: logs still remain in /var/dashboard/logs"
echo "to remove:"
echo "rm /var/dashboard/logs/log-cpu-temp.log"
echo "rm /var/dashboard/logs/log-cpu-temp-history.log"
