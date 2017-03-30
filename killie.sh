#!/bin/bash

# killie.sh - kill IE/wineserver so memory doesn't ballon too much

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv2

# NOTE: this is so old, at least six years, needed it to kill IE fast
# as memory would ballon quickly. Not used anymore, needed for an
# IE only webapp

# Use ps to find PID's of IEXPLORE or wineserver
wine=`ps aux | grep -i [w]ineserver | awk '$11 {print $2}'`
ie=`ps aux | grep -i [I]EXPLORE | awk '$11 {print $2}'`

# Check if any instances of IEXPLORE or wineserver return 0 (not running)
if [ "$ie" == "0" ]; then
    pids2kill=( $wine $ie)
	  for item in ${pids2kill[@]}; do
		    # need processname otherwise will show blank since it is after we kill PID
		    processname=`ps --pid $item | grep -v CMD | awk '{print $4}'`
		    kill -9 $item

		    if [ $? -eq 0 ]; then
			      echo "Killed PID ${item}, (${processname})"
		    else
			      echo "Unable to kill PID ${item}, (${processname})"
		    fi 
    done
else
	  echo "No IE process(es) found, nothing to do. Exiting."
fi

#EOF