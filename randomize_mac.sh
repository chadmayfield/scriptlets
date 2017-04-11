#!/bin/bash

# randomize_mac.sh - randomize mac address

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# NOTE: This was meant to be a quick and easy way to get around things like
# free wifi time limits, nothing more. It was a quick experiment to build a 
# tool myself like macchanger or spoofMAC. Even though it was an experiment
# I began using it all the time.  

# if not already root, become root
if [ $UID -ne 0 ]; then
    echo "ERROR: You must be root!"
    exit 1
fi

revert=0
if [ $# -eq 1 ]; then
    if ! [[ $1 =~ "revert" ]]; then
        echo "ERROR: Invalid option, it must be --revert to revert back!"
        echo "to the default MAC address!"
        echo "  e.g. $0 --revert"
        exit 1
    else
        revert=1
    fi
fi

# store original hw mac here
sentinel=~/.default_hw_mac

# we'll default to openssl for random hex generation
command -v openssl >/dev/null 2>&1; i_can_haz_ssl=1 || { i_can_haz_ssl=0; }

# let define a few default prefixes so our mac addresses look legitimate
# entire list is here: http://standards.ieee.org/regauth/oui/oui.txt
# Unicast:    x2:, x6:, xA:, xE:
# Multicast:  x3:, x7:, xF:
# NSA J125:   00:20:91
# VMware:     00:50:56:00 to 00:50:56:3F
# Xen:        00:16:3E
# VirtualBox: 0A:00:27 (v5)
#             08:00:27 (v4)

# define prefix from above
prefix=('08:00:27:' '0A:00:27:' '00:16:3E:' '00:50:56:' '00:20:91:')

# the meat
if [[ $OSTYPE =~ "darwin" ]]; then
	idx=$( jot -r 1  0 $((${#prefix[@]} - 1)) )
	sel=${prefix[idx]}
	
    default_iface=$(route -n get default | grep interface | awk '{print $2}')
    default_mac=$(ifconfig $default_iface | grep ether | awk '{print $2}')

    if [ $revert -eq 1 ]; then
        if [ ! -f $sentinel ]; then
            echo "ERROR: Unable to revert, can't find $sentinel! Try rebooting."
            exit 1
        else
            original_mac=$(cat $sentinel)
            echo "Original MAC address found: $original_mac"
        fi

        # change it back to default
        echo "Reverting it back..."
        ifconfig $default_iface ether $original_mac

        # verify that it was changed
        test_mac=$(ifconfig $default_iface | grep ether | awk '{print $2}')
        if [ "$test_mac" == "$original_mac" ]; then
            echo "Succeessfully changed MAC!"
            rm -f $sentinel
        else
            echo "MAC Address change unsuccessful."
            exit 1
        fi
        exit 1
    fi

    # set a sentinel file to keep track of real mac
    if [ -f $sentinel ]; then
        if [ $(cat $sentinel) != "$default_mac" ]; then
            # keep the mac in sentinel as default
            default_mac=$(cat $sentinel)
        fi
    else
        # first run, have to touch or it dies
        touch $sentinel
        echo $default_mac > $sentinel
    fi

    printf "%-20s %s\n" "Default Interface:" $default_iface
    printf "%-20s %s\n" "Default MAC Address:" $default_mac

    # generate part of a new mac address
    if [ "$i_can_haz_ssl" -eq "1" ]; then
        random_mac=$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//')
        new_mac="${sel}${random_mac}"
        printf "%-20s %s\n" "Random MAC Address:" ${new_mac}
    else
        #random_mac=$()
        echo "Coming Soon!"
    fi

    # make the change
    ifconfig $default_iface ether $new_mac

    # verify that it was changed
    test_mac=$(ifconfig $default_iface | grep ether | awk '{print $2}')
    if [ "$test_mac" == "$new_mac" ]; then
        echo "Succeessfully changed MAC!"
    else
        echo "MAC Address change unsuccessful."
    fi

elif [[ $OSTYPE =~ "linux" ]]; then
	sel=${prefix[$RANDOM % ${#prefix[@]} ]}
	
    default_iface=$(route | grep '^default' | grep -o '[^ ]*$')
    default_mac=$(ifconfig $default_iface | awk '/HWaddr/ {print $5}')

    if [ $revert -eq 1 ]; then
        if [ ! -f $sentinel ]; then
            echo "ERROR: Unable to revert, can't find $sentinel! Try rebooting."
            exit 1
        else
            original_mac=$(cat $sentinel)
            echo "Original MAC address found: $original_mac"
        fi

        # change it back to default
        echo "Reverting it back..."
        # bring the interface down (alt/old:  ifconfig $default_iface down)
        echo "ip link set dev $default_iface down"

        # change the mac address (alt/old: ifconfig eth0 hw ether $new_mac)
        echo "ip link set dev $default_iface address $new_mac"

        # bring the interface up (alt/old: ifconfig eth0 up)
        echo "ip link set dev $default_iface up"

        # verify that it was changed
        test_mac=$(ip link show $default_iface | awk '/ether/ {print $2}')
        #test_mac=$(ifconfig $default_iface | awk '/HWaddr/ {print $5}')
        if [ "$test_mac" == "$original_mac" ]; then
            echo "Succeessfully changed MAC!"
            rm -f $sentinel
        else
            echo "MAC Address change unsuccessful."
            exit 1
        fi
        exit 1
    fi

    # set a sentinel file to keep track of real mac
    if [ -f $sentinel ]; then
        if [ $(cat $sentinel) != "$default_mac" ]; then
            # keep the mac in sentinel as default
            default_mac=$(cat $sentinel)
        fi
    else
        # first run
		touch $sentinel
        echo $default_mac > $sentinel
    fi

    printf "%-20s %s\n" "Default Interface:" $default_iface
    printf "%-20s %s\n" "Default MAC Address:" $default_mac

    # generate part of a new mac address
    if [ "$i_can_haz_ssl" -eq "1" ]; then
        random_mac=$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//')
        new_mac="${sel}${random_mac}"
        printf "%-20s %s\n" "Random MAC Address:" ${new_mac}
    else
        random_mac=$(head -n 10 /dev/urandom | tr -dc 'a-fA-F0-9' | \
                     fold -w 12 | head -n 1 | fold -w2 | paste -sd: - | \
                     tr '[:upper:]' '[:lower:]')
        new_mac="${sel}${random_mac}"
        printf "%-20s %s\n" "Random MAC Address:" ${new_mac}
    fi

    # make the change

    # bring the interface down (alt/old:  ifconfig $default_iface down)
    ip link set dev $default_iface down || \
        echo "ERROR: Unable to bring $default_iface down!"; exit 1

    # change the mac address (alt/old: ifconfig eth0 hw ether $new_mac)
    ip link set dev $default_iface address $new_mac || \
        echo "ERROR: Unable to chnage $default_iface MAC!"; exit 1

    # bring the interface up (alt/old: ifconfig eth0 up)
    ip link set dev $default_iface up || \
        echo "ERROR: Unable to bring $default_iface up!"; exit 1

    # verify that it was changed (alt: ifconfig $default_iface | grep HWaddr)
    test_mac=$(ip link show $default_iface | awk '/ether/ {print $2}')
    if [ "$test_mac" == "$new_mac" ]; then
        echo "Succeessfully changed MAC!"
    else
        echo "MAC Address change unsuccessful."
    fi

else
    echo "ERROR: Unknown OSTYPE!"
fi

#EOF
