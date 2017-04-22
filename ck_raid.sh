#!/bin/bash

# raid_check.sh - check status of raid using MegaCli64

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# example output for drive/adapter status ($megacli -LDInfo -LALL -aAll)
#Virtual Drives    : 1 
#  Degraded        : 0 
#  Offline         : 0 
#Physical Devices  : 4 
#  Disks           : 4 
#  Critical Disks  : 0 
#  Failed Disks    : 0

debug=0
megacli="/opt/MegaRAID/MegaCli/MegaCli64"
tmpfile="/tmp/megacli.out.$$"
alertlog="/tmp/alert.log.$$"
email="user@domain.tld"
subject="WARNING: Problems with RAID array on $(hostname)!"

if [ $UID -ne 0 ]; then
    echo "ERROR: You must be root to run this utility!"
    exit 1
fi

if [ ! -f $megacli ]; then
    echo "ERROR: Cannot find MegaCli64! You must install it to continue."
    exit 1
fi

info() {
    # grab adapter info
    $megacli -AdpAllInfo -aAll > $tmpfile
    regexp="^(Product|FW (P|V)|BIOS V|Supported|Failed|  Offline)|(Virtual|Physical) D(evice|rive)s|Serial No|Memory S|Host Int|Degraded|Disks|Critical"

    while read line
    do
        name=$(echo $line | awk -F ":" '{print $1}')
        ver=$(echo $line | awk -F ":" '{print $2}')

        if [[ $name =~ (Degraded|Offline|Disks) ]]; then
            printf "  %-19s %s\n" "$name" "$ver"
        else
            printf "%-21s %s\n" "$name" "$ver"
        fi
    done < <(grep -E "$regexp" $tmpfile)
    printf "Virtual Drive Info\n"
    unset regexp

    # grab logical drive info
    $megacli -LDInfo -LALL -aAll > $tmpfile
    regexp="^(RAID|S(ize|ector|trip|pan)|Number)"

    while read line
    do
        name=$(echo $line | awk -F: '{print $1}')
        ver=$(echo $line | awk -F: '{print $2}')
        printf "  %-19s %s\n" "$name" "$ver"
    done < <(grep -E "$regexp" $tmpfile)
    unset regexp

    state=$(grep -E '^State' $tmpfile | awk -F: '{print $2}')
    printf "%-21s %s\n" "Drive Status" "${state^^}"

    # grab physical information
    $megacli -PDList -aAll > $tmpfile
    regexp="Slot|Firmware state|Inquiry"

    while read line
    do
        name=$(echo $line | awk -F ":" '{print $1 $2}')
        ver=$(echo $line | awk -F ":" '{print $2}' | sed 's/^[[:space:]]*//g')

        # get slot/state
        if [[ $line =~ "Slot" ]]; then
            printf "  %-21s" "$name"
        elif [[ $line =~ "state" ]]; then
            printf "%-21s" "$ver"
        fi

        # get serial numebr
        if [[ $line =~ "Inquiry Data" ]]; then
            drive=$(echo $line | grep 'Inquiry'| awk -F: '{print $2}'| \
                    awk '{print $1}')
            printf "$drive\n"
        fi
    done < <(grep -E "$regexp" $tmpfile)
    unset regexp
}

monitor() {
    do_exit=0
    $megacli -LDInfo -LALL -aAll > $tmpfile
    $megacli -AdpAllInfo -aAll >> $tmpfile

    # remove a couple of things to make regexp easier to write
    sed -i '/Coercion Mode/d' $tmpfile
    sed -i '/Offline VD/d' $tmpfile
    sed -i '/Force Offline/d' $tmpfile

    regexp="^State|Degraded|Offline|Disks"

    while read line
    do
        name=$(echo $line | awk -F ":" '{print $1}')
        ver=$(echo $line | awk -F ":" '{print $2}')

        # check each line for concerning items... if debug=1 tee so see output
        if [[ $line =~ "State" ]]; then
            if [ $ver != "Optimal" ]; then
                if [ $debug -eq 1 ]; then
                    echo "STATE: $ver" | tee -a $alertlog
                else
                    echo "STATE: $ver" >> $alertlog
                fi
                let do_exit+=1
            fi
        elif [[ $line =~ "Degraded" ]]; then
            if [ $ver -ne 0 ]; then
                if [ $debug -eq 1 ]; then
                    echo "ERROR: $ver Disks Degraded" | tee -a $alertlog
                else
                    echo "ERROR: $ver Disks Degraded" >> $alertlog
                fi
                let do_exit+=1
            fi
        elif [[ $line =~ "Offline" ]]; then
            if [ $ver -ne 0 ]; then
                if [ $debug -eq 1 ]; then
                    echo "ERROR: $ver Disks Offline" | tee -a $alertlog
                else
                    echo "ERROR: $ver Disks Offline" >> $alertlog
                fi
                let do_exit+=1
            fi
        elif [[ $line =~ "Critical" ]]; then
            if [ $ver -ne 0 ]; then
                if [ $debug -eq 1 ]; then
                    echo "ERROR: $ver Critical Disks" | tee -a $alertlog
                else
                    echo "ERROR: $ver Critical Disks" >> $alertlog
                fi
                let do_exit+=1
            fi
        elif [[ $line =~ "Failed" ]]; then
            if [ $ver -ne 0 ]; then
                if [ $debug -eq 1 ]; then
                    echo "ERROR: $ver Failed Disks" | tee -a $alertlog
                else
                    echo "ERROR: $ver Failed Disks" >> $alertlog
                fi
                let do_exit+=1
            fi
        fi

        printf "%-15s %s\n" "$name" "$ver" >> /tmp/stats.log.$$

    done < <(grep -E "$regexp" $tmpfile)
}

case $1 in
    info)
        info
        ;;
    monitor|status)
        monitor

        echo "--------------------" >> $alertlog
        cat /tmp/stats.log.$$ >> $alertlog

        if [ $do_exit -ge 1 ]; then
            mail -s "$subject" $email < $alertlog
            rm -f $alertlog /tmp/stats.log.$$
            exit 99
        fi
        ;;
    *)
        echo "ERROR: Unknown option! Please change the option and try again."
        echo "  e.g. $0 <info|monitor>"
        exit 1
esac

#EOF
