# Refresh Dashboard Values

Many of the values shown on the dashboard are 'cached' - stored in files so that the dashboard pages load quickly. While these values may get out of alignment with actual values, they will get refereshed over time.

However, sometimes one wants to know right now. So this script will run the dashboard monitor_scripts that update the cached values, and, hopefully, load proper values. Sometimes though, docker is slow so values won't get loaded. Wait a minute and retry.

**How To Use**

There are two ways to run this script.  
[1] Install it:  
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/refresh_dashboard/install.sh -O - | sudo bash  

To run:  
sudo ./refresh-dash.sh

[2] Run from cloud (without install):  
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/refresh_dashboard/just_run.sh -O - | sudo bash  

**Sudo Required**

This script requires sudo privileges because it 1) uses the monitor_scripts to run privileged commands and 2) those commands write to the dashboard cached files.  

**Install or Run From Cloud?**
It maybe safer and certainly easier if you want to run often. Safer because you download one time and can read the script, and changes only happen if you update it.

Running from cloud will always run latest version, and you can read the [just_run.sh script](https://github.com/lt-columbo/pisces_tools/blob/main/refresh_dashboard/just-run.sh) which just runs the [refresh_dash.sh script](https://github.com/lt-columbo/pisces_tools/blob/main/refresh_dashboard/refresh-dash.sh) before running, but can be easy to not check. All of the commands in this script are in the dashboard's monitor_scripts directory: /etc/monitor_scripts/

There is nothing in this script as written that is harmful.
