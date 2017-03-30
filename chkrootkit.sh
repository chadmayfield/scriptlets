#!/bin/bash

# chkrootkit.sh - run chkrootkit then log & email results

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

#set -e # immediately exit if non-zero exit

logrotate_enabled=0 # if logrotate enabled change to 1
email_to='root@localhost'

bin_path=/usr/sbin/chkrootkit
logfile=/var/log/chkrootkit.log
required=( chkrootkit egrep mail ) # required binaries
start_time=$(date)
host=$(hostname -f)
exclude='no suspect files|not (found|infected|promisc)|nothing (deleted|detected|found)'
email_sub="[chkrootkit] $host $start_time"
fail=0

# functions start
log() {
    echo "$(date): $@" >> $logfile
}

bail() {
    echo "$(date): $@" >> $logfile
    exit 2
}

log_rotate() {
    if [ $logrotate_enabled -eq 0 ]; then
        if [ ! -f $logfile]; then
            bail "error: no logfile exists" # bail, log rotation won't work
        fi
        
        # modified from http://stackoverflow.com/a/3690996
        for suffix in {8..1}; do
            if [ -f "$logfile.${suffix}" ]; then
                ((next = suffix + 1))
                mv -f "$logfile.${suffix}" "$logfile.${next}"
            fi
        done
        mv -f "$logfile" "$logfile.1"
    else
        log "internal log rotation disabled"
    fi
}

check_logs() {
    if [ -e $logfile ]; then
        if [ -s $logfile ]; then
            log "using current empty logfile" # it's empty
        else
            log_rotate # need to rotate
        fi
    else
        touch $logfile &> /dev/null || echo "unable to create log file"
    fi
}

check_depends() {
    # check for required programs
    for i in ${required[@]};
    do
        hash $i &> /dev/null || log "required but not found: $i"
        if [ $? -ne 0 ]; then
            fail=1;
        fi
    done
    
    # TODO: send email that we are bailing
    
    if [ $fail -ne 0 ]; then
        bail "error: un-met dependencies"
    fi
}

send_mail() {

}

# start main program
log "start time: $start_time"
log "hostname: $host"

check_depends  # check for dependencies
check_logs     # check for clean logfile/rotation

# finally execute chkrootkit
$bin_path | egrep -v $exclude &> $logfile

# grab logfile email
cat $logfile | mail -s $email_sub email_to

#/usr/sbin/chkrootkit | egrep -v 'no suspect files|not (found|infected|promisc)|nothing (deleted|detected|found)' | mail -s "[chkrootkit] `hostname -f` `date`" root@localhost

#EOF