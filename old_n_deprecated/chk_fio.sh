#!/bin/bash

# chk_fio.sh - check status of fio

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

errors=0
rthreshold=80   # percentage 
alertlog="/tmp/alert.log.$$"
email="user@domain.tld"
subject="WARNING: Problems with Fusion-io drive on $(hostname)!"

regexp="(Board|Internal) t|Media|status:|fct?.*Product|Flashback|bytes (w|r)|Current|Peak"

if [ $UID -ne 0 ]; then
    echo ERROR: You must be root to run this utility!""
fi

command -v fio-status >/dev/null 2>&1 || { \
    echo >&2 "ERROR: You must install fio-status to continue!"; exit 1; }

command -v bc >/dev/null 2>&1 || { \
    echo >&2 "ERROR: You must install bc to continue!"; exit 1; }

# we don't have a fio character device
if [ ! -c /dev/fct* ]; then
    echo "ERROR: No character device found! Are you sure you have FIO card?"
    exit 1
fi

# we've got a device, do we have a block device
if [ ! -b /dev/fio* ]; then
    echo "ERROR: No FIO block device found! Is the drive installed & working?"
    exit 1
fi

# check if we have an ext4 filesystem
if [ ! -d "$(mount | grep /dev/fio* | awk '{print $3}')/lost+found" ]; then
    echo "ERROR: No file system found on $(mount | grep /dev/fio* | awk '{print $1}')"
    exit 1
fi

info() {
    # just print out what's interesting, w/o formatting
    while read -r line
    do
        if [[ $line =~ (Current|Peak) ]]; then
            echo "RAM $line"
        else
            if [[ $line =~ "bytes" ]]; then
                size=$(echo $line | awk -F ": " '{print $2}' | sed -e 's/,//g')
                c=$(bc <<< "scale=2; $size / 1024 / 1024 / 1024")

                echo "$line ($c GB)"
            else
                echo $line
            fi
        fi
    done< <(fio-status -a | grep -E "$regexp")
}

check_health() {
    while read -r line
    do
        # add every line to $alertlog to email if there are errors
        if [[ $line =~ (Current|Peak) ]]; then
            echo "RAM $line" >> $alertlog
        elif [[ $line =~ "bytes" ]]; then
            size=$(echo $line | awk -F ": " '{print $2}' | sed -e 's/,//g')
            c=$(bc <<< "scale=2; $size / 1024 / 1024 / 1024")
            echo "$line ($c GB)" >> $alertlog
         else
            echo $line >> $alertlog
        fi

        # if health is anything other than heathly...alert
        if [[ $line =~ "status:" ]]; then
            state=$(echo $line |awk -F": " '{print $2}' |awk -F";" '{print $1}')

            if [ $state != "Healthy" ]; then
                let errors+=1
            fi
        fi

        # if flashback is more than 50% used...alert
        if [[ $line =~ "Flashback" ]]; then
            # how much flashback is used
            fback=$(echo $line | awk -F ": " '{print $2}' | \
                    awk -F "/" '{print $1}')
            # what is the flashback available
            fb_ttl=$(echo $line | awk -F ": " '{print $2}' | \
                     awk -F "/" '{print $2}')
            # set our threshold to 50% flashback usage
            threshold=$(bc <<< "scale=0; $fb_ttl / 2")

            if [ $fback -ge $threshold ]; then
                let errors+=1
            fi
        fi

        # if block reserves dip below 80%...alert
        if [[ $line =~ "Reserves" ]]; then
            # little dirty, but it works
            reserves=$(echo $line | awk -F "s: " '{print $3}' | \
                       awk -F "%" '{print $1}' | awk -F. '{print $1}')

            if [ $reserves -lt $rthreshold ]; then
                let errors+=1
            fi
        fi
    done< <(fio-status -a | grep -E "$regexp")

    # if errors are detects, send alert email
    if [ $errors -ge 1 ]; then
        #echo "send email"
        mail -s "$subject" $email < $alertlog
    fi

    # debug email
    #cat $alertlog

    # we're done, cleanup
    rm -f $alertlog
}

case $1 in
    info)
        info
        ;;
    health)
        check_health
        ;;
    *)
        echo "ERROR: Unknown option! Please change the option and try again."
        echo "  e.g. $0 <info|health>"
        exit 1
esac

#EOF
