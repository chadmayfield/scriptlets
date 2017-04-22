#!/bin/bash

# randomize_hostname.sh - randomize hostname 

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# NOTE: This is ***totally untested***, don't use this yet!

if [ $UID -ne 0 ]; then
    echo "ERROR: You must run this as root to change the hostname!"
    exit 1
fi

if [ "$1" == "permanent"]; then
    perm=1
fi

# store our original hostname
h=/etc/.original_hostname
svc_file=/etc/systemd/system/hostname.service

# our list of possible hostnames
names=(lust gluttony greed sloth wrath envy pride prudence justice 
       temperance courage faith hope charity)

create_service() {
cat << EOF > /etc/systemd/system/hostname.service
[Unit]
Description=Randomize hostname on boot

[Service]
Type=oneshot
ExecStart=/bin/bash /usr/local/bin/randomize_hostname.sh permanent

[Install]
WantedBy=multi-user.target
EOF
}

if [[ $OSTYPE =~ "darwin" ]]; then
    # get random element
    idx=$( jot -r 1  0 $((${#names[@]} - 1)) )
    sel=${names[idx]}

    # find old hostname (or hostname/uname -a)
    orig_hostname=$(sysctl kern.hostname | awk '{print $2}')
    if [ -e $h  ]; then
        if [ $(cat $h) != "$orig_hostname" ]; then
            echo "Storing original hostname..."
            echo "$orig_hostname" > $h
        fi
    fi

    if [ $perm -eq 1 ]; then
        # for permanent hostname change like this:
        hostname -s $sel
    else
        # temporarily change hostname (or hostname $sel)
        echo "scutil –-set HostName $sel"
    fi

    if [ $(hostname) == "$sel" ]; then
        echo "Successfully changed hostname to: $sel"

        if [ $perm -eq 1 ]; then
            echo "Please reboot this machine to complete the change."
        fi
    else
        echo "ERROR: Unable to change hostname! Please try again."
        exit 2
    fi

elif [[ $OSTYPE =~ "linux" ]]; then
    # get random element
    sel=${names[$RANDOM % ${#names[@]} ]}

    # old hostname (or hostname/uname -n/ cat /proc/sys/kernel/hostname)
    orig_hostname=$(sysctl kernel.hostname | awk '{print $3}')
    if [ -e $h  ]; then
        if [ $(cat $h) != "$orig_hostname" ]; then
            echo "Storing original hostname..."
            echo "$orig_hostname" > $h
        fi
    fi

    if [ $perm -eq 1 ]; then
        # create systemd.service file /lib/systemd/system/hostname.service
        # should put system-wide custom services in /etc/systemd/system
        # or /etc/systemd/user or ~/.config/systemd/user for user mode.
        if [ ! -f $svc_file ]; then
            create_service_file
            #chown /etc/systemd/system/hostname.service
            #chmod /etc/systemd/system/hostname.service
        fi

        if [ -f /etc/redhat-release ]; then
            # Red Hat variant
            sed -i "s/^HOSTNAME=.*$/HOSTNAME=$sel/g" /etc/sysconfig/network
        elif [[ $(lsb_release -d) =~ [Debian|Ubuntu] ]]; then
            # Debian/Ubuntu variants
            echo $sel > /etc/hostname
        else
            echo "ERROR: Unknown distro!"
        fi

        # modify /etc/hosts
        #sed -i "s/$oldhostname/$sel/g"
    else
        # temporarily change hostname
        echo "hostname $sel"
    fi

    if [ $(hostname) == "$sel" ]; then
        echo "Successfully changed hostname to: $sel"

        if [ $perm -eq 1 ]; then
            :
            #echo "Please reboot this machine to complete the change."
        fi
    else
        echo "ERROR: Unable to change hostname! Please try again."
        exit 2
    fi

else
    echo "ERROR: Unknown OS!"
fi

#EOF
