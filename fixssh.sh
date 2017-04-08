#!/bin/bash

# fixssh.sh - fix bad ssh keys from server OVER-deployment, a quick hack and
#             useless re-engineering of 'ssh-keygen -R <hostname>'

# NOTE: Reinvent the wheel, yup I did it. I fequently deploy a lot of servers
# which are DHCP/DNS'd so when the SSH keys regenerate I always used to get key
# errors, so I have this gem.... before I discovered 'ssh-keygen -R <hostname>'

if [ $* -ne 1 ]; then
    echo "Usage: $0 <hostname|ip address>"
    exit 1
fi

remove="$*"
knownhosts="~/.ssh/known_hosts"
removedhosts="~/.ssh/removed_hosts"

if [ $(grep -c $remove $knownhosts) -ge 1 ]; then
    for server in $remove; do
        # copy the key to remove to $removedhosts
        cat $hostfile | grep $remove > $removedhosts
        echo "SUCCESS: Added $remove to $removedhosts"
 
        # remove the key ($remove)
        cat $hostfile | grep -v $server > ${knownhosts}.$$
        mv -fp ${knownhosts}.$$ $knownhosts
        #sed -i '/$remove/'d $knownhosts
        echo "SUCCESS: Removed $remove from $knownhosts"
    done
else
    echo "ERROR: $remove not found in $knownhosts"
fi

#EOF
