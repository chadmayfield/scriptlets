#!/bin/bash

# redirect_logging.sh - redirect logging example

#xhost + &> /dev/null

# logging routine.
>/var/log/mylog.log
chmod 666 /var/log/mylog.log

# assign descriptor 3 as a duplicate STDOUT link, then out to logfile
# good explanation: http://tldp.org/LDP/abs/html/io-redirection.html
exec 3>&1
exec 1>/var/log/my.log 2>&1

eko () {
  # echo args to stdout and log file
  echo "$@" >&3
  echo "$@"
}

eko "Hello World!"

# disable writing to logfile by group/other
chmod 644 /var/log/mylog.log

#EOF
