#!/bin/bash

# status_myrepos.sh - get status of all my repos under the current tree to make
#                     sure they don't have uncommitted changes

# git status all repositories in tree
for i in $(ls -d */)
do
    cd $i

    if [ -e .git ]; then
        repo=$(git config --local -l | grep "remote.origin.url" | awk -F "=" '{print $2}')
        echo -e "Found repo: \033[1m$repo\033[0m"
        #echo "Current changes..."
        git status -s
    else
        :
    fi

    cd ..
#    sleep 2
done

#EOF
