#!/bin/bash

# update_myrepos.sh - update all my repos under the current tree

if [ $(ps -ef | grep " ssh-agen[t]" | wc -l) -eq 0 ]; then
    echo "ssh-agent is not running, starting it..."

    # easy way to grab failure without set -e set
    # http://stackoverflow.com/a/14389672
    if eval $(ssh-agent -s); then
        # success
        :
    else
        # failure
        echo "start failed!" && exit 1
    fi
fi

if [ $(ssh-add -l | grep -v "no identities" | wc -l) -eq 0 ]; then
    echo "no ssh key found in agent! add it with ssh-add;"
    echo "  e.g. ssh-add ~/.ssh/id_rsa"
    exit 1
fi

# git pull all repositories in tree
for i in $(ls -d */)
do
    cd $i

    if [ -e .git ]; then
        repo=$(git config --local -l | grep "remote.origin.url" | awk -F "=" '{print $2}')
        echo "Found repo: $repo"
        echo "Pulling latest changes..."
        git pull
    else
        :
    fi

    cd ..
done

#EOF
