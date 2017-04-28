#!/bin/bash

# rkhunter.sh - run rkhunter then log & email results

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

command -v logrotate >/dev/null 2>&1; logrotate=1 || { logrotate=0; }
command -v rkhunter >/dev/null 2>&1 || \
    { echo >&2 "ERROR: rkhunter isn't installed!"; exit 1; }

if [ $UID -ne 0 ]; then
    echo "ERROR: You must be root to run this utility!"
    exit 1
fi

# set which package manager we should use
if [ -f /etc/os-release ]; then
    pkgmgr=RPM
elif [[ $(lsb_release -a 2> /dev/null | grep Desc) =~ (Ubuntu|Debian) ]]; then
    pkgmgr=DPKG
elif [[ $OSTYPE =~ "darwin" ]]; then
    pkgmgr=BSD
else
    pkgmgr=NONE
fi

# we want logrotate to rotate the logs weekly
if [ $logrotate -eq 1 ]; then
    echo "checking if logrotate has been configured..."

    if [ $(grep -c rkhunter /etc/logrotate.d/*) -ne 1 ]; then
        #/var/log/rkhunter/rkhunter.log {
        #    weekly
        #    notifempty
        #    create 640 root root
        #}
        echo "skipping logrotate autoconf, not implemented yet"
    else
        echo "rkhunter is already configured in logrotate"
    fi
fi

# where's our logs?
logfile="/var/log/rkhunter/rkhunter.log"

# runtime options
rkhunter="command rkhunter"
ver_opts="--rwo --nocolors --versioncheck"
upt_opts="--rwo --nocolors --update"
run_opts="-c --nomow --nocolors --syslog --pkgmgr $pkgmgr --cronjob --summary"

# mail config
mail_to='user@domain.tld'
mail_from="root@$(hostname)"
subject="RKHUNTER: Scan results for $(hostname)."

# version check
$rkhunter $ver_opts 

# run an update
$rkhunter $upt_opts

# finally run
$rkhunter $run_opts

# send an email
mail -s "$subject" $mail_to < $logfile

#EOF
