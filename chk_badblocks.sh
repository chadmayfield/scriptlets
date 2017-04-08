#!/bin/bash
#
# chk_badblocks.sh - check hard drives for bad blocks to be called with a 
#                    single argument, the device as shown in /dev.  
#                    for example; ./chk_badblocks.sh /dev/sda
#

# should be root
if [ $UID -ne 0 ]; then
  echo "$0 must be run as root"
  exit 1
fi

# print usage if no args are passed
if [ $# -ne 1 ]; then
  echo "usage: $0 <device>"
  exit 1
fi

# set some variables
is_destructive=0   # (0=no, 1=yes)
ldevice=${1%/}     # long device name
sdevice=`echo ${1%/} | sed 's/\/dev\///'`
logfile=chk_badblocks_${sdevice}.log
passes=20
mail="chad@planetmayfield.com"

# let's begin
echo "Beginning run of chk_badblocks." >> $logfile
echo "Run information" >> $logfile
echo "  Device: $ldevice" >> $logfile
echo "  Passes: $passes" >> $logfile

if [ $is_destructive -eq 0 ]; then
  echo "  Destructive: NO" >> $logfile
else
  echo "  Destructive: YES" >> $logfile
fi

# actually run badblocks
count=0
while [ $count -lt $passes ]; do
  echo "---" >> $logfile
  echo "Pass: $count" >> $logfile
  echo "Start time: $(date)" >> $logfile
  stime=$(date +%s)

  # run either a destructive or non-destructive badblocks run
  if [ $is_destructive -eq 0 ]; then
    # non-destructive
    badblocks -nsv -o bb_${sdevice}.txt $1 >> $logfile
  else
    # destructive
    badblocks -wsv -o bb_${sdevice}.txt $1 >> $logfile
  fi

  etime=$(date +%s)
  echo "End time: $(date)" >> $logfile
  elapsed=`expr $etime - $stime`
  echo "Elapsed time: `expr $elapsed \/ 60` minutes" >> $logfile
  echo "---" >> $logfile
  let count=count+1
done

# mail results
mailx -s "chk_badblocks.sh finished on $passes on $1" $mail < ./chk_badblocks_${sdevice}.log
