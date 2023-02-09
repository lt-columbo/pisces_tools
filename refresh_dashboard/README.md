# Refresh Dashboard Values

**What This Does**  
Many of the values shown on the dashboard are 'cached' - stored in files so that the dashboard pages load quickly. While these values may get out of alignment with actual values, they will get refreshed over time.

However, sometimes one wants to know right now. So this script will run the dashboard monitor-scripts that update the cached values, and, hopefully, load proper values. Sometimes though, docker is slow so values won't get loaded. So if values are still messed up, wait a minute and retry.

**How To Use**  
There are two ways to run this script.  
**[1] Install it:**  
sudo wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/refresh_dashboard/install.sh -O - | sudo bash  

To run:  
sudo ./refresh-dash.sh

**[2] Run from cloud (without install):**  
sudo wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/refresh_dashboard/refresh-dash.sh -O - | sudo bash   

**Sudo Required**  
This script requires sudo privileges because it 1) uses the monitor_scripts to run privileged commands and 2) those commands write to the dashboard cached files.  

**Install or Run From Cloud?**  
It may be safer and certainly easier if you want to run often. Safer because you download one time and can read the script, and changes only happen if you update it so can get behind a version.

Running from cloud will always run latest version, and you can read the [refresh-dash.sh script](https://github.com/lt-columbo/pisces_tools/blob/main/refresh_dashboard/refresh-dash.sh) before running. All of the commands in this script are in the dashboard's monitor-scripts directory: /etc/monitor-scripts/

There is nothing in this script as written that is harmful.

**Screen Stalls Downloading??**  
sudo wants your password. Type it in press enter. Or if paranoid, cancel, run `sudo ls` then rerun the wget command above and sudo will have cached password.

