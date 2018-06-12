#!/bin/bash

# update_myrepos.sh - update all my repos under the current tree

keys=( "$HOME/.ssh/github.com/id_ed25519" ) 

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

# check if ssh-agent is running & start it
if [ $(ps -A | grep "[s]sh-agent -s" | wc -l) -eq 0 ]; then
    echo "ssh-agent is not running!"
    echo "starting..."
    eval "$(ssh-agent -s)"
else
    echo "ssh-agent is already running."
fi

echo "checking for key..."
for i in ${keys[@]}; do
	# grab key fingerprint
    cmp_key=$(ssh-keygen -lf $i)
	
	# if key fingerprint not found in fingerprint list, add it
	if [ $(ssh-add -l | grep -c "$cmp_key") -eq 0 ]; then
    	echo "key not found."
    	echo "adding key..."
		ssh-add $i
	else
    	echo "key found."
	fi
done

# iterate through all child dirs to find git repos
echo "pulling updates..."
for i in $(find $(pwd) -name .git | sed 's/\/.git//g' | sort)
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
		git pull --tags
    else
        :
    fi
    )
done

#EOF