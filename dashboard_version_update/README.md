# Pisces Dashboard Version Number Update Patch
This patch will update the version number shown on the bottom of the dashboard from 0.2.8 to 0.2.9. It does nothing else and leaves rest of dashboard intact.

**To run**

Copy paste the command below into the ssh shell of the miner:

wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/dashboard_version_update/patch_version.sh -O - | sudo bash

**What it does**

This patch updates the file /var/dashboard/version to contain the value 0.2.9 if the version in the file is 0.2.8/

**What it does not do**

This patch does not update the dashboard only the version number.

**Restoring old version file**

The prior version data is in the file /var/dashboard/version.last
To restore the original version, run this command:
sudo cp /var/dashboard/version.last /var/dashboard/version
