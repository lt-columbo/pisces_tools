# Dashboard Patch for Pisces Dashboard v0.2.9

### Patches dashboard so the the status values show properly and the update works again

### This patch makes changes to these 8 scripts in /etc/monitor-scripts that need updating for the new helium_gateway 1.0.0+

* auto-maintain.sh
* helium-statuses.sh
* info-height.sh
* miner.sh
* miner-update.sh
* miner-version-check.sh
* peer-list.sh
* pubkeys.sh

### This patch makes changes to one file in the dashboard in /var/dashboard/public/index.php that corrects the link when 'update available' shows to point to the update miner page. 

* index.php

### In addition it adds one new script, that allows one to refresh all of the dashboard values that get out of date and confuse things.

* refresh-dash.sh

# To update your miner via ssh

**sudo wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_patch/install.sh -O - | sudo bash**

Each of the scripts updated get backed up in two ways:
* into a unix tar file in admin home directory /home/admin/monitor-scripts.tar.bz2"
* into files in /etc/monitor-scripts:

  - /etc/monitor-scripts/auto-maintain.sh.old
  - /etc/monitor-scripts/helium-statuses.sh.old
  - /etc/monitor-scripts/info-height.sh.old
  - /etc/monitor-scripts/miner.sh.old
  - /etc/monitor-scripts/miner-update.sh.old
  - /etc/monitor-scripts/miner-version-check.sh.old
  - /etc/monitor-scripts/peer-list.sh.old
  - /etc/monitor-scripts/pubkeys.sh.old

### You can identify the patch has been applied by Miner Height showing as 9YYYYJJJR (YYYY=Year, JJJ=Julian Date, Release No) Example: 920230720 2023=Year, 072=72nd Day of Year, 0=Release (just in case needed to indicate updates on same day)

**Anytime you desire you may refresh the dashboard cache. To do this: run the refresh-dash.sh script**  

Run at any time:
sudo sh /etc/monitor-scripts/refresh-dash.sh

# Undoing this Update for any reason  
If you want to revert, you can copy these files back over or reinstall the dashboard by running the update. There is a revert script available:
sudo /etc/monitor-scripts/revert.sh

Or you can to by hand, one by one:

***To RESTORE OLD SCRIPTS by copying the files back over***  
- sudo cp /etc/monitor-scripts/auto-maintain.sh.old /etc/monitor-scripts/auto-maintain.sh
- sudo cp /etc/monitor-scripts/helium-statuses.sh.old /etc/monitor-scripts/helium-statuses.sh
- sudo cp /etc/monitor-scripts/info-height.sh.old /etc/monitor-scripts/info-height.sh
- sudo cp /etc/monitor-scripts/miner.sh.old /etc/monitor-scripts/miner.sh
- sudo cp /etc/monitor-scripts/miner-update.sh.old /etc/monitor-scripts/miner-update.sh
- sudo cp /etc/monitor-scripts/miner-version-check.sh.old /etc/monitor-scripts/miner-version-check.sh
- sudo cp /etc/monitor-scripts/peer-list.sh.old /etc/monitor-scripts/peer-list.sh
- sudo cp /etc/monitor-scripts/pubkeys.sh.old /etc/monitor-scripts/pubkeys.sh
- sudo cp ~admin/index.php.old /var/dashboard/public/index.php
- 
