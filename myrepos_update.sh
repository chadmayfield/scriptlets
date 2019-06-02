#!/bin/bash

# update_myrepos.sh - update all my repos under the current tree

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

fail=0
keys=( "$HOME/.ssh/hosting/src/id_ed25519" )

bold=$(tput bold)       
normal=$(tput sgr0)
black=$(tput setaf 0)    # COLOR_BLACK/RGB:0,0,0
red=$(tput setaf 1)      # COLOR_RED/RGB:255,0,0
green=$(tput setaf 2)    # COLOR_GREEN/RGB:0,255,0
yellow=$(tput setaf 3)   # COLOR_YELLOW/RGB:255,255,0
blue=$(tput setaf 4)     # COLOR_BLUE/RGB:0,0,255
magenta=$(tput setaf 5)  # COLOR_MAGENTA/RGB:255,0,255
cyan=$(tput setaf 6)     # COLOR_CYAN/RGB:0,255,255
white=$(tput setaf 7)    # COLOR_WHITE/RGB:255,255,255

for i in ${keys[@]}; do
    if ! [ -f "$i" ]; then
        echo "Key doesn't exist: $i"
        let fail+=1
    fi
done

if [ "$fail" -ne 0 ]; then
    echo "ERROR: Unable to find key(s)!"
    exit 1
fi

echo "Checking for ssh-agent..."

# find all ssh-agent sockets
#$find / -uid $(id -u) -type s -name *agent.\* 2>/dev/null()

# set var if not set
oursock="$HOME/.ssh/.ssh-agent.$HOSTNAME.sock"

# is $SSH_AUTH_SOCK set
if [ -z "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK=$oursock
else
    # it is, but check to make sure it's not keyring
    if ! [ "$SSH_AUTH_SOCK" = $oursock ]; then
        export SSH_AUTH_SOCK=$oursock
    fi
fi

# if we don't have a socket, start ssh-agent
if [ ! -S "$SSH_AUTH_SOCK" ]; then
    echo "Not found! Starting ssh-agent..."
    eval $(ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null)
    start_rv=$?
    echo $SSH_AGENT_PID > $HOME/.ssh/.ssh-agent.$HOSTNAME.sock.pid

    if [ "$start_rv" -eq 0 ]; then
        echo "Started: $SSH_AUTH_SOCK (PID: $SSH_AGENT_PID)"
    else
        echo "ERROR: Failed to start ssh-agent! (EXIT: $start_rv)"
        exit 1
    fi
else
    echo "Found: $SSH_AUTH_SOCK"
fi

## recreate pid
#if [ -z $SSH_AGENT_PID ]; then
#    export SSH_AGENT_PID=$(cat $HOME/.ssh/.ssh-agent.$HOSTNAME.sock.pid)
#fi

# use the correct grammar for fun!
if [ "${#keys[@]}" -eq 1 ]; then
    echo "Checking for key..."
else
    echo "Checking for keys..."
fi

for i in "${keys[@]}"; do
    # grab key fingerprint
    cmp_key=$(ssh-keygen -lf $i)
        
    # if key fingerprint not found in fingerprint list, add it
    if [ $(ssh-add -l | grep -c "$cmp_key") -eq 0 ]; then
        echo "Key not found! Adding it..."
        ssh-add $i
        add_rv=$?

        if [ $add_rv -eq 0 ]; then
            echo "Key added."
        fi
    else
        echo "Key already added: $(echo $cmp_key | awk '{print $2}')"
    fi
done

# iterate through all child dirs to find git repos
DIR="$(pwd)/"
echo "Pulling updates... (${DIR})"
for i in $(find "$DIR" -name .git | grep -vE "go/src/|.old_repos" | sed 's/\/.git//g' | sort)
do
    (
    cd "$i"

    if [ -e .git ]; then
        repo=$(git config --local -l | grep "remote.origin.url" | awk -F "=" '{print $2}')
        echo " "

        if [[ $repo =~ "@" ]]; then
            repotype="SSH"
        else
            repotype="HTTPS"
        fi

        echo "====================================================="
        echo "${bold}Found repo ($repotype): ${yellow}$repo${normal}"
        echo "Pulling latest changes..."
        git pull
        #git pull --tags
    fi
    cd - > /dev/null 2>&1
    )
done

#EOF
