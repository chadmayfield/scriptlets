#!/bin/bash

# json_parse_with_python - parse json output with python in a shell script

# example output
#{
#    "ip": "166.70.163.62",
#    "hostname": "166-70-163-62.xmission.com",
#    "city": "Midvale",
#    "region": "Utah",
#    "country": "US",
#    "loc": "40.6092,-111.8819",
#    "org": "AS6315 Xmission, L.C.",
#    "postal": "84047"
#}

# grab ip info in json format
headers=$(curl -s http://ipinfo.io)

# fields also contain 'postal', but don't care about it
fields=(ip hostname city region country loc org)

for i in ${fields[@]}
do
    printf "%-20s %s\n" "$i" "$(echo $headers | \
    python -c 'import json,sys;obj=json.load(sys.stdin);print obj["'$i'"]';)"
done

#EOF
