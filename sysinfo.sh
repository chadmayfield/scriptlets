#!/bin/bash

# sysinfo.sh - get hw stats for differnet oses

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3
# date    : 04/19/2009 (updated 04/05/2017)

# TODO:
#   + Add Drive information
#   + Fix uptime to display entire uptime
#   + Parameterize better

if [[ $1 =~ "help" ]]; then
    echo "$0, displays basic system information, such as uptime, load, & IP's."
    echo "  e.g. $0"
    echo ""
    echo "To view info AND established connections;"
    echo "  $0 --connections"
    exit 1
fi

# source secret tokens
tokenpath="$HOME/.secrets"
if [ -f "$tokenpath" ]; then
    source "$tokenpath"
else
    echo "ERROR: $tokenpath doesn't exist!"
    exit 1
fi

# grab some basic information
currdate=$(date)
kernel=$(uname -sr)

# check if docker is installed
command -v docker >/dev/null 2>&1; has_docker=1 || { has_docker=0; }

# check if ifconfig is installed
command -v ifconfig >/dev/null 2>&1 || \
    { echo >&2 "ERROR: I require 'ifconfig' but it's not installed!"; exit 1; }

# if docker is installed set some variables
if [ $has_docker -eq 1 ]; then
    if [[ $OSTYPE =~ "linux" ]]; then
        # check if current user is in docker group
        does_user_exist=$(grep docker* /etc/group | grep -c "$(whoami)")
        
        if [ "$does_user_exist" -ge 1 ] || [ "$UID" -eq 0 ]; then
            docver=$(docker version |grep -A3 Server | awk '/Version/ {print $2}')
            running=$(docker ps | grep -v CONTAINER | awk '{print $1"|"$NF}')
        else
            docver=">>>FOR THIS STAT, RUN AS ROOT<<<"
            running=">>>FOR THIS STAT, RUN AS ROOT<<<"
        fi

        docip=$(ifconfig docker0 | grep "inet " | awk '{print $2}' |grep -v ":")
        int_ip=$(ip -br -4 addr | grep UP | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    elif [[ $OSTYPE =~ "darwin" ]]; then
        docver=$(docker version |grep -A3 Server | awk '/Version/ {print $2}')                         
        running=$(docker ps | grep -v CONTAINER | awk '{print $1"|"$NF}') 
        int_ip=$(ifconfig | grep "inet.*broadcast" | awk '{print $2}')
    fi
else
    int_ip=$(ifconfig | grep "inet.*broadcast" | awk '{print $2}')
fi

# get external ip address
command curl -s "https://ipinfo.io?token=${IPINFO_KEY}" > /tmp/ext_ip || \
    { echo >&2 "ERROR: You must be connected to the internet!"; exit 1; }
ext_ip=$(grep ip /tmp/ext_ip | awk '{gsub(/[",]/, ""); print $2}')
ext_hn=$(grep hostname /tmp/ext_ip | awk '{gsub(/[",]/, ""); print $2}')

# set variables depending on os (between macOS & Ubuntu/Debian/RHEL)
if [[ $OSTYPE =~ "darwin" ]]; then
    up=$(uptime | awk 'BEGIN{FS="up |,"}{print $2" hours"}'|awk '{$1=$1};1')

    # get some OS/HW specific information
    os_name=$(sw_vers -productName)
    os_version=$(sw_vers -productVersion)
    os_build=$(sw_vers -buildVersion)
    serial=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
    # get hw version: http://apple.stackexchange.com/a/98089
    hw=$(curl -s https://support-sp.apple.com/sp/product?cc=$(echo $serial | \
        cut -c 9-) | sed 's|.*<configCode>\(.*\)</configCode>.*|\1|')
    uuid=$(system_profiler SPHardwareDataType | awk '/UUID/ { print $3 }')

    # get load stats
    load=$(uptime | awk 'BEGIN{FS="averages:"}{print $2}' | cut -c2-)

    # get cpu info
    cpu_model=$(sysctl -n machdep.cpu.brand_string)
    physical_cpus=$(sysctl -n hw.physicalcpu)
    cores=$(sysctl -n machdep.cpu.core_count)
    virt_cores=$(sysctl -n hw.ncpu)
    proc_flags=$(sysctl -n machdep.cpu.extfeatures)
    proc_flags+=$(sysctl -n machdep.cpu.leaf7_features)

    # get memory info
    ttl_mem=$(hostinfo | awk '/available:/ {print $4" "$5}')
    ### serveral other ways to get total memory on macos
    #ttl_mem=$(sysctl hw.memsize | awk 'print $2')
    #ttl_mem=$(ps -caxm -orss= | awk '{ sum += $1 } END { print sum/1024 }')
    mem=$(top -l 1 -s 0 | grep PhysMem | awk -F ': ' '{print $2}') 

    # additional network information
    txrx="$(netstat -ib -I en0 | grep -v Name | head -n1 | awk '{print $10}') bytes"
    conn=$(netstat -anf inet | awk '{print $5}' | grep [0-9] | \
       grep -vE 'x|127.0.0.1' | awk -F . '{print $1"."$2"."$3"."$4}' |sort -u)

    # get drive/mount point information
#    drives=$(diskutil list)
elif [[ $OSTYPE =~ "linux" ]]; then
    up=$(uptime -p | cut -d " " -f2-)

    # get some OS/HW specific information
    if [ -f /etc/redhat-release ]; then
        os_version=$(cat /etc/redhat-release)
    else
        os_version=$(lsb_release -ds)
    fi

    serial="None"

    # test whether user can use dmidecode
    a=$( { dmidecode -q > /tmp/dmitest; rm -f /tmp/dmitest; } 2>&1)
    if [[ $a =~ "denied" ]]; then
        hw=">>>FOR THIS STAT, RUN AS ROOT<<<"
        uuid=">>>FOR THIS STAT, RUN AS ROOT<<<"
    else
        hw=$(dmidecode --type system | grep -E 'Manuf|Product'|\
             awk -F ": " '{print $2}' | paste -sd ' ' -)
        uuid=$(dmidecode | grep "UUID:" | awk '{print $2}')
    fi

    # get load stats
    loc="/proc/cpuinfo"
    load=$(uptime | awk 'BEGIN{FS="average:"}{print $2}'| cut -c2-)

    # get cpu info
    cpu_model=$(grep '^model name' $loc | uniq | awk -F ": " '{print $2}')
    physical_cpus=$(grep 'physical id' $loc | sort | uniq | wc -l)
    cores=$(grep 'cpu cores' $loc | uniq | awk 'BEGIN{FS=": "}{print $2}')
    virt_cores=$(grep ^processor $loc | wc -l)
    proc_flags=$(grep 'flags' $loc | uniq | awk 'BEGIN{FS=": "}{print $2}')

    # get memory info
    ttl_mem=$(free -tm | grep Mem: | awk '{printf "%.2f gigabytes\n",$2/1024}')
    mem=$(free -th |grep Mem: |awk '{print $3" used (of "$2"), "$4" unused. "}')

    # additional network information
    txrx=$(ifconfig | grep -A3 $int_ip | awk '/RX/ {print $6" "$7}' | \
            sed -e 's/[()]//g')
    conn=$(netstat -nat | awk '{print $5}' | grep [0-9] | \
           grep -vE 'x|127.0.0.1|0.0.0.0' | awk -F ":" '{print $1}')

    # get drive/mount point information
#    drives=$(fdisk -l)
else
    echo "ERROR: Unknown \$OSTYPE!"
    exit 1
fi

echo "------------------------------------------------------------------------"
printf "%-20s %s\n" "Current Date:" "$currdate" 
printf "%-20s %s\n" "Hostname:" "$(hostname)"

if [[ $OSTYPE =~ "darwin" ]]; then
    printf "%-20s %s %s (%s)\n" "OS:" "$os_name" "$os_version" "$os_build"
else
    printf "%-20s %s\n" "OS:" "$os_version"
fi

printf "%-20s %s\n" "Kernel:" "$kernel"
printf "%-20s %s\n" "HW Version:" "$hw"
printf "%-20s %s\n" "HW Serial:" "$serial"
printf "%-20s %s\n" "HW UUID:" "$uuid"
printf "%-20s %s\n" "Uptime:" "$up"
printf "%-20s %s\n" "Load Average:" "$load"
printf "%-20s %s\n" "Processor:" "$cpu_model"
printf "%-20s %s\n" "Core Count:" "$cores"
printf "%-20s %s\n" "Virtual Cores:" "$virt_cores"

#if [[ $OSTYPE =~ "linux" ]]; then
#    printf "%-20s %s" "Flags:"
#    echo "$proc_flags" | fold -s -w 59 | sed -e "2,\$s/^/$(echo $'\t' | pr -Te21)/"
#fi

printf "%-20s %s\n" "Total Memory:" "$ttl_mem"
printf "%-20s %s\n" "Memory Used:" "$mem"
printf "%-20s %s (Tx/Rx: %s)\n" "Internal IP:" "$int_ip" "$txrx"

if ! [[ $OSTYPE =~ "darwin" ]]; then
    printf "%-20s %s (%s)\n" "External IP:" "$ext_ip" "$ext_hn"
fi

# if docker is install, print stats
if [ $has_docker -eq 1 ]; then
    printf "%-20s %s\n" "Docker Version:" "$docver"

    if [ $(docker ps | grep -v IMAGE | wc -l) -ne 0 ]; then
        printf "%-20s %s %s\n" "Containers:" "CONTAINER ID       NAME"
        for i in ${running[@]}
        do
            printf "%-20s %s\n" "" "$(echo $i | awk -F"|" '{print $1"\t"$2}')"
        done
    fi
fi

# print current connections is arg is connections
if [[ $1 =~ "connections" ]]; then
    printf "%-20s %s\n" "Current Connections:" "$int_ip"
    for i in ${conn[@]}
    do
        rdns=$(host $i | awk '{print $NF}' | uniq)
        if [[ $rdns =~ (NXDOMAIN|PTR|record|SERVFAIL) ]]; then
            printf "%-20s %s\n" " " "$i"
        else
            printf "%-20s %s (%s)\n" " " "$i" "$rdns"
        fi
    done
fi

echo "------------------------------------------------------------------------"

rm -f /tmp/ext_ip

#EOF
