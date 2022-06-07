#!/bin/bash
is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }

if ! is_user_root
then
  echo "This script must be run as root because of pi command: vcgencmd is privileged"
  exit 1
fi

count=1
interval=5
# get command line options
while getopts fi:c: flag
do
  case $flag in
  # -f is follow mode, we do quick cheat and set high limit at 2m
  c) if ((count > 1))
       then
          echo "-c (count) and -f (follow) options are exclusive, use one or the other"
          exit 1
       fi
       var=$OPTARG
       if [ -n "$var" ] && [ "$var" -eq "$var" ] 2>/dev/null;
         then
           count=$var
         else
           echo "option -c (count) is not a number"
           exit 1
         fi
         ;;
  f) if ((count > 1))
            then
               echo "-c (count) and -f (follow) options are exclusive, use one or the other"
               exit 1
            fi
     count=2000000
	   echo "Follow mode active - use Ctrl-C to stop"
     ;;
   # -i option is interval between voltage tests
  i) var=$OPTARG
  if [ -n "$var" ] && [ "$var" -eq "$var" ] 2>/dev/null;
    then
      interval=${var-}
    else
      echo "option -i (interval) is not a number"
      exit 1
    fi
    ;;
   ?) echo "usage: $0 "
      echo "   -i=interval in seconds between voltage checks (default is 5)"
      echo "   -c=number of times to run before stopping"
      echo "   -f follow: run forever"
      echo " Examples:"
      echo " sudo ./$0 -f run forever, sampling every 5 seconds"
      echo " sudo ./$0 -f -i 10 run forever sample every 10 seconds"
      echo " sudo ./$0 -c 6  sample 6 times every 5 seconds"
      exit 1
      ;;
  esac
done
# get voltage from raspberrypi count times
i=0
while [ $i -lt $count ]
  do
   echo "    "
   for id in core sdram_c sdram_i sdram_p
     do
       echo -e "$id:\t$(vcgencmd measure_volts $id)"
     done
   i=$((i+1))

   # sleep interval seconds except on last one
   if [ $i -lt $count ]
     then
          # send ctrl-c to break msg every 5 times
          modval=$((i % 5))
          if [ $modval -eq 0 ]
            then
              echo "    "
              echo "Continuing ... use Ctrl-C to stop"
          fi
       sleeptime=$interval
       sleeptime+='s'
       sleep $sleeptime
   fi
done
