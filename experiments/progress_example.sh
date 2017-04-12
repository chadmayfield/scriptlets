#!/bin/bash

# progress_example.sh - feedback of progress while waiting for work to complete

pidile=/var/run/appname/appname.pid
if [ ! -e $pidfile ]; then
    touch $pidfile
fi

CNT=0

# watch and wait for the process to terminate
echo -n "Waiting for appname to close cleanly"
while [ -e $pidfile ];
do
    echo -n "."
    sleep 1

    let CNT=CNT+1

    # process has not terminated in 3 minutes, kill it
    if [ $CNT -gt 180 ]; then
        rm -f $pidfile
        #kill -9 appname
        echo "termination timeout exceeded, killing appname"
        exit 1
    fi
done
echo "the appname has been terminated"

#EOF
