#!/bin/bash

# measure_latency.sh - a dirty measure of latency via ping

# NOTE: This was only written so I could test latency quickly if I needed
#       to while in the terminal (which is where I spend all my time). If
#       you really want to view latency over time, use smokeping

usage() {
    echo "  e.g. $0 <hostname/ip> <count>"
}

if [ $# -ne 2 ]; then
    echo "ERROR: You must supply a hostname/IP to measure & a packet count!"
    usage
    exit 1
fi

server=$1
count=$2
success=0

if [[ $OSTYPE =~ "darwin" ]]; then
    # mac ping has different options that on linux
    while read line
    do
        # check if we successfully ran
        if [[ $line =~ "round-trip" ]]; then
            latency=$(echo $line | awk -F "/" '/round-trip/ {print $7}')
            echo "latency to $server with $count packets is: $latency"
            success=1 && exit 0
        fi

        # check packet loss if we didn't run correctly
        if [[ $line =~ "transmitted" ]] && [[ $success -ne 1 ]]; then
            pct=$(echo $line | awk '/transmitted/ {print $(NF-2)}' | \
                   awk -F. '{print $1}')

            # check packet loss
            if [ $pct -eq 100 ]; then
                loss=$(echo $line |awk '/tted/ {print $(NF-2),$(NF-1),$NF}')
                echo "latency measurement failed: $loss"
            fi
        fi
    done < <(ping -q -c $count -i 0.2 -t 3 $server)
    
elif [[ $OSTYPE =~ "linux" ]]; then
    # http://homepage.smc.edu/morgan_david/cs70/assignments/ping-latency.htm
    while read line
    do
        # check if we successfully ran
        if [[ $line =~ "rtt" ]]; then
            latency=$(echo $line | awk -F "/" '/rtt/ {print $5 " ms"}')
            echo "latency to $server with $count packets is: $latency"
            success=1 && exit 0
        fi

        # check packet loss if we didn't run correctly
        if [[ $line =~ "transmitted" ]] && [[ $success -ne 1 ]]; then
            pct=$(echo $line |awk '/transmitted/ {print $6}' | sed 's/%//g')

            # check packet loss
            if [ $pct -eq 100 ]; then
                loss=$(echo $line |awk '/mitted/ {print $6" "$7" "$8}' | \
                       sed 's/,//g')
                echo "latency measurement failed: $loss"
            fi
        fi
    done < <(ping -q -c $count -i 0.2 -w 3 $server)
	
else
    echo "ERROR: Unknown OS ($OSTYPE)"
fi

#EOF
