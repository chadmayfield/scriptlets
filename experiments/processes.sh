#!/bin/bash

# processes.sh - manipulation of linux processes

echo "PID = $$"

pid=$$
if [ -z $pid ]; then
    read -p "PID: " pid
fi

ps -p ${pid:-$$} -o ppid=

#EOF
