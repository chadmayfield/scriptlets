#!/bin/bash

# update_other_repos.sh - update the 'other' repos cloned under the current tree

# git pull all repositories in tree
for i in $(find . -name .git | sed 's/.git//g')
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
