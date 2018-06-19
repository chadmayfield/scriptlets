#!/bin/bash

# add-keys.sh: add my ssh keys to agent 

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

fail=0
keys=( "$HOME/.ssh/github.com/id_ed25519" 
       "$HOME/.ssh/gogs/id_ed25519" 
       "$HOME/.ssh/helios/id_ed25519" 
       "$HOME/.ssh/selene/id_ed25519" )

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

#EOF
