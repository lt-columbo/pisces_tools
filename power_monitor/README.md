# Power Monitor

**A simple script to repeatedly run Raspberry Pi voltage samples**

# Usage
usage: sudo ./power_monitor.sh 
   -i=interval in seconds between voltage checks (default is 5)
   -c=number of times to run before stopping (default is 1)
   -f=follow: run forever
   
 Examples:
 sudo ././power_monitor.sh -f run forever, sampling every 5 seconds
 sudo ././power_monitor.sh -f -i 10 run forever sample every 10 seconds
 sudo ././power_monitor.sh -c 6  sample 6 times every 5 seconds

# To Install

Run this command:

wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/power_monitor/install.sh -O - | sudo bash

# Sample Output

core:	volt=0.8500V
sdram_c:	volt=1.1000V
sdram_i:	volt=1.1000V
sdram_p:	volt=1.1000V

# Privileges Required

Must be run as sudo because of privileged Raspberry Pi `vcgencmd` is used
