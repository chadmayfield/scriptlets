#!/bin/bash

# vagrant_update_boxes.sh - update all vagrant boxes under current directory

for i in $(find . -name Vagrantfile)
do
    if ! [[ $i =~ (do|vultr)- ]]; then
        echo "Found Vagrantfile at: $i"
        cd $(echo $i | sed 's/Vagrantfile//')

        boxname=$(grep "^  config.vm.box " Vagrantfile | awk -F "= " '{print $2}')
        echo "Updating box: $boxname"

        vagrant box update

        cd - &> /dev/null
        echo "============================================================"
    fi
done

#EOF
