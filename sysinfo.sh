#!/bin/bash

# sysinfo.sh - get hw stats for differnet oses

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3
# date    : 04/19/2009 (updated 04/05/2017)

# TODO:
#   + Add Network Tx/Rx Totals
#   + Add Drive information
#   + Add USB device information

b=$(tput bold)
n=$(tput sgr0)

currdate=$(date)
up=$(uptime | awk 'BEGIN{FS="up |,"}{print $2$3" hours"}')
kernel=$(uname -sr)
command curl -s http://ipinfo.io > /tmp/ext_ip
int_ip=$(ifconfig | grep "inet.*broadcast" | awk '{print $2}')
ext_ip=$(grep ip /tmp/ext_ip | awk '{gsub(/[",]/, ""); print $2}')
ext_hn=$(grep hostname /tmp/ext_ip | awk '{gsub(/[",]/, ""); print $2}')

if [[ $OSTYPE =~ "darwin" ]]; then
    load=$(uptime | awk 'BEGIN{FS="averages:"}{print $2}')
    cpu_model=$(sysctl -n machdep.cpu.brand_string)
    physical_cpus=$(sysctl -n hw.physicalcpu)
    cores=$(sysctl -n machdep.cpu.core_count)
    virt_cores=$(sysctl -n hw.ncpu)
    proc_flags=$(sysctl -n machdep.cpu.extfeatures | fold -w 40)
    proc_flags+=$(sysctl -n machdep.cpu.leaf7_features | fold -w 60)
    ttl_mem=$(hostinfo | awk '/available:/ {print $4" "$5}')
    ### serveral other ways to get total memory on macos
    #ttl_mem=$(sysctl hw.memsize | awk 'print $2')
    #ttl_mem=$(ps -caxm -orss= | awk '{ sum += $1 } END { print sum/1024 }')
    mem=$(top -l 1 -s 0 | grep PhysMem | awk -F ': ' '{print $2}') 
#    drives=$(diskutil list)
elif [[ $OSTYPE =~ "linux" ]]; then
    loc="/proc/cpuinfo"
    load=$(uptime | awk 'BEGIN{FS="average:"}{print $2}')
    cpu_model=$(grep '^model name' $loc | uniq | awk -F ": " '{print $2}')
    physical_cpus=$(grep 'physical id' $loc | sort | uniq | wc -l)
    cores=$(grep 'cpu cores' $loc | uniq | awk 'BEGIN{FS=": "}{print $2}')
    virt_cores=$(grep ^processor $loc | wc -l)
    proc_flags=$(grep 'flags' $loc | uniq | awk 'BEGIN{FS=": "}{print $2}')
    ttl_mem=$(free -tm | grep Mem: | awk 'printf "%.2f gigabytes\n,$2/1024"')
    mem=$(free -th |grep Mem:|awk '{print $1" used (of "$2"), "$3" unused. "}')
#    drives=$(fdisk -l)
else
    echo "ERROR: Unknown \$OSTYPE!"
    exit 1
fi

echo "-----------------------------------"
echo "Current System Information Snapshot"
echo "-----------------------------------"
echo "${b}Current date:${n} $currdate"
echo "${b}Hostname:${n} $(hostname)"
echo "  ${b}Uptime:${n} $up"
echo "  ${b}Load average:${n}${load}"
echo "  ${b}Kernel:${n} $kernel"
echo "${b}Prcoessor Information:${n} $cpu_model"
echo "  ${b}Processor Cores:${n} $cores"
echo "  ${b}Virtual Processors:${n} $virt_cores"
#echo "  ${b}Processor Flags:${n} $proc_flags"
echo "${b}Memory Information:${n} $ttl_mem"
echo "  ${b}Memory stats:${n} $mem"
echo "${b}Network Information${n} "
echo "  ${b}Internal Address:${n} $int_ip"
echo "  ${b}External Address:${n} $ext_ip (${ext_hn})"
#echo "  ${b}Total Tx/Rx$:{n} "
#echo "${b}Drive Information${n} "
#echo "$drives"
echo "-----------------------------------"

rm -f /tmp/ext_ip

#EOF
