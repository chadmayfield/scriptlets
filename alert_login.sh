#!/bin/bash

# alert_login.sh - notify <some_user> when anyone logs into system

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

if ! [[ $OSTYPE =~ "linux" ]]; then
    echo "ERROR: This may only be run on Linux!"
    exit 1
fi

command -v mail >/dev/null 2>&1 || { \
        echo >&2 "ERROR: You must install mail to continue!"; exit 1; }

command -v route >/dev/null 2>&1 || { \
        echo >&2 "ERROR: You must install route to continue!"; exit 1; }

date=$(date)
who_am_i=$(whoami)
users=$(w)
our_host=$(hostname -f)

dflt_iface=$(route | grep '^default' | grep -o '[^ ]*$')
local_ip=$(ip addr show "$dflt_iface" | grep "inet " | awk '{print $2}' | \
           sed -e 's/\/.*$//g')

# check if local or remote connection
if [[ $(tty) =~ "pts" ]]; then
    # pseudo terminal
    local_ip=$(echo "$SSH_CONNECTION" | awk '{print $3}')
    local_wan=$(curl -s http://ipinfo.io/ip)
    local_rdns=$(curl -s http://ipinfo.io/hostname)

    remote_ip=$(echo "$SSH_CONNECTION" | awk '{print $1}')
    if [[ $remote_ip =~ (::1|127.0.0.1) ]]; then
        remote_ip="NONE (reverse tunnel?)"
    fi
    remote_rdns=$(host "$remote_ip")

    # check to see if we can resolve the connecting ip
    regexp="not found|PTR|NXDO"
    if [[ $remote_ip =~ "$regexp" ]]; then
        remote_rdns="N/A"
    fi
elif [[ $(tty) =~ "tty" ]]; then
    # console
    remote_ip="tty$(tty | awk -F "tty" '{print $2}')"
    remote_rdns="None, logged in locally!"
else
    # who knows how anyone got here
    remote_ip="UNKNOWN"
    remote_rdns="UNKNOWN"
fi

tmpfile="/tmp/alert_login.txt.$$"
mail_to='user@domain.tld' # change this to alert user
subject="ALERT: Login to $our_host from $remote_ip"

# I know, normally I hate HTML email, but for this, I wanted it and this
# is a pretty cool way to do it.
cat > $tmpfile << EOF
<html>
<head>
<title>ALERT: Login to $our_host from $remote_ip</title>
</head>
<body>
Dear <b>$mail_to</b>,

<p>For security reasons we inform you about each login to your server. If you 
received this notification but you did not login, please log 
into your server as soon as possible and check your logs! <b>Note:</b> if you 
don't want to receive such notifications please remove the 
/etc/profile.d/${0##*/} file.</p>

<table>
<tr><td><strong>Date: </strong></td><td>$date</td></tr>
<tr><td><strong>Hostname: </strong></td><td><a href="http://${our_host}/">$our_host</a> ($local_ip)</td></tr>
<tr><td><strong>User: </strong></td><td>$who_am_i (id=${UID})</td></tr>
<tr><td><strong>Location: </strong></td><td>$(tty)</td></tr>
<tr><td><strong>WAN IP: </strong></td><td><a href="http://ipinfo.io/$local_wan">$local_wan</a> ($local_rdns)</td></tr>
<tr><td><strong>Remote IP: </strong></td><td><a href="http://whois.domaintools.com/$remote_ip">$remote_ip</a></td></tr>
<tr><td><strong>Remote rDNS: </strong></td><td><a href="#">$remote_rdns</a></td></tr>
<tr><td><br /></td><td><br /></td></tr>
<tr><td><strong>Uptime/Users: </strong></td><td><pre>${users}</pre></td></tr>
<tr><td><br /></td><td><br /></td></tr>
<tr><td><strong>Current Connections: </strong></td><td><pre>$(netstat -n -A inet)</pre></td></tr>
<tr><td><br /></td><td><br /></td></tr>
</table>

<br /><br />----<br />Regards,
<br />admin@$our_host<br />
</body>
</html>
EOF

# send out the email
mail -s "$(echo -e "$subject \nContent-type: text/html")" "$mail_to" < $tmpfile

# cleanup
rm -f $tmpfile

#EOF
