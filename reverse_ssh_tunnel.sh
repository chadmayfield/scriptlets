#!/bin/bash

# reverse_ssh_tunnel.sh - create reverse ssh tunnel from current host to jumpbox

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# NOTE: If keys are not setup you'll need to supply your password twice, once
#       for the test and once for the connection. I created this becuase on
#       certain servers I create reverse shells to bypass firewalls and leave
#       them running for a long time, so I always have to look up on a cheat
#       sheet the syntax, with this script I don't have to remember syntax!

if [ $# -ne 3 ]; then
    echo "ERROR: You must supply the args; username hostname and port"
    echo "  e.g. $0 <username> <hostname> <port>"
    exit 1
fi

user=$1
host=$2
port=$3

# must be a valid port
if [[ $port -lt 0 ]] || [[ $port -gt 65536 ]]; then
    echo "ERROR: Invalid port, ($port), please use a port between 1-65536!"
    exit 1
fi

# crude check to see if we have connectivity
if [ $(ping -c 1 -p $port $host | awk '/transmitted/ {print $(NF-2)}' | awk -F. '{print $1}') -eq 100 ]; then
    echo "ERROR: Unable to ping $host:$port! Are you sure it's up?"
    exit 1
fi

ck_if_tunnel_exists() {
    # check to see if the tunnel exists on the remote host
    netstat_test="netstat -tunla | grep -c 127.0.0.1:7000"
    tunnel_test=$(ssh -l $user -p $port $host "$netstat_test")
    
    if [ $tunnel_test -ne 0 ]; then
        echo "ERROR: There's already a tunnel running on $host! Please use it."
        exit 2
    fi
}

create_reverse_tunnel() {
    echo "No port is running, proceeding to create one..."
    
    # create tunnel in background without executing commands 
    ssh -fN -p $port -R 7000:localhost:22 ${user}@${host}

    tunnel_rv=$?

    if [ $tunnel_rv -eq 0 ]; then
        echo "Tunnel created successfully! You can now connect to $host and run"
        echo "ssh -p 7000 user@localhost to connect back to this machine."
    else
        echo "ERROR: There was a problem creating the reverse tunnel!"
        exit 3
    fi
}

ck_if_tunnel_exists
create_reverse_tunnel

#EOF
