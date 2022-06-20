## DO NOT USE YET

## Log CPU Temperature for Pisces Miners

**What it does**  
This tool will create a scheduled 'cronjob' that will run every 15 minutes capturing the CPU temperator of the Raspberry Pi into logs.  

**To Install**  
To Install the tool, run the command below in the Pisces Secure Shell (ssh):  
sudo wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/cpu_temp_monitor/install.sh

**To Remove**  
To remove the tool, run the command below on your Pisces miner:  
sudo wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/cpu_temp_monitor/remove.sh

**NOTE**: The remove tool leaves the logs in place. You must remove these yourself if you no longer want them. That way you won't lose data unless you choose to.  

**To remove the logs manually:**  
sudo rm /var/dashboard/logs/log-cpu-temp.log  
sudo rm /var/dashboard/logs/log-cpu-temp-history.log  

**What are the logs and where are they**  
There are two logs maintained by the tool:
cpu-temp.log - contains the last 24 hours of logs, 96 entries
cpu-temp-history.log - a perpetual log that contains all logged temperature captures.

The logs are stored in the dashboard logs directory at /var/dashboard/logs  

**Format of the logs**  
The files are in csv format and look like this:  
61.3,2022-06-19,21:30  
60.3,2022-06-19,21:45  
61.8,2022-06-19,22:00  
63.3,2022-06-19,22:15  

**How to view the logs**  
You may view a graph of the last 24 hours by accessing this url in the Pisces Dashboard:  
https://<your_miner_ip>/graph_cpu_temp.php  

Unfortunately, there are several versions of the dashboard and integrating directly (links in the dashboad) seems unfeasable. Coming soon, I'll supply a patch file for the original briffy dashboard 0.29

You may also use an editor or the cat/tail tools to echo the values to the ssh shell.  
To show the last 18 entries of the cpu-temp-history.log use:  
tail -18 /var/dashboard/logs/cpu-temp-history.log  
To 'follow' the log (see new entries as they arrive - every 15 minutes):  
tail -f /var/dashboard/logs/cpu-temp-history.log  

You may also export the files by ftp to any place you have access to.
