#!/bin/bash

# status_myrepos.sh - get status of repos that have changes to commit under current tree

for i in $(find . -name .git | sed 's/\/.git//g' | sort)
do
    cd $i

    if [ -e .git ]; then
        repo=$(git config --local -l | grep "remote.origin.url" | awk -F "=" '{print $2}')

        # only show repos that have changes
        if [ $(git status -s | wc -l | awk '{print $1}') -gt 0 ]; then
            echo -e "Repo : \033[1m$repo\033[0m"
            echo -e "Path : \033[0;34m$(pwd)\033[0m"
            git status -s
        fi
    fi

    cd - > /dev/null 2>&1
done

#EOF
