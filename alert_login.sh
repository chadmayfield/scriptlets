#!/bin/bash

# alert_login.sh - send specified user alert whenever anyone logs in

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

# add script with +x perms to /etc/profile.d/

# TODO:
#   - fix script so when root logs in it doesn't throw erros
#   - fix certain ip's (such as 70.103.189.14) rDNS may be broken

MAILTO="user@domain.tld"
DATE=$(date)

W_AMI=$(whoami)
W_LOGGEDIN=$(w)
MY_HOSTNAME=$(hostname -f)
SSH_IP=$(echo $SSH_CONNECTION)
IP=$(echo $SSH_IP | awk '{print $1}')
HOST=$(host $IP)
RDNS=$(echo $HOST | awk '{print $5}' | sed -e 's/.$//g')

SUBJECT="$MY_HOSTNAME SSH login $DATE"

if [ `echo $HOST | grep -c "not found"` -ge 1 ]; then
    RDNS="NOT FOUND"
fi

echo "
----------------------
  LOGIN NOTIFICATION
----------------------

Date: ${DATE}
Host: $(hostname -f)
User: ${W_AMI}

Origin IP: ${IP}
Origin rDNS: ${RDNS}


--- System Uptime --------------------------
$(uptime)

--- Logged in users ------------------------
${W_LOGGEDIN}

--- Established connections ---------------
$(netstat -n -A inet)

--------------------------------------------




--- SYSTEM PROCESS INFORMATION -------------

$(ps afux)

--------------------------------------------
" >> /tmp/login_alert.txt


/usr/bin/mail -s "`hostname -f` SSH login [$DATE]" $MAILTO < /tmp/login_alert.txt

rm /tmp/login_alert.txt


#echo -e "$DATE\n\nUser \"$WHO\" has logged from $IP ($REVERSE)." | /usr/bin/mail -s "`hostname -f` SSH login `date`" user@domain.tld

