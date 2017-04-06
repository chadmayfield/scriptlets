#!/bin/bash

# sysinfo.sh - get hw stats for differnet oses

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3
# date    : 04/19/2009 (updated 04/05/2017)

b=$(tput bold)
n=$(tput sgr0)

CURRENT=$(date)
UP=$(uptime | awk 'BEGIN{FS="up |,"}{print $2$3" hours"}')
PLATFORM=$(uname -sr)

if [[ $OSTYPE =~ "darwin" ]]; then
	LOAD=$(uptime | awk 'BEGIN{FS="averages:"}{print $2}')
    CPU=$(sysctl -n machdep.cpu.brand_string)
#	PHYSPROC=$(sysctl -n hw.physicalcpu)
	PROCORES=$(sysctl -n machdep.cpu.core_count)
    VIRTPROC=$(sysctl -n hw.ncpu)
	FLAGS=$(sysctl -n machdep.cpu.extfeatures)
	FLAGS+=$(sysctl -n machdep.cpu.leaf7_features)
#	TTL_MEM=$(ps -caxm -orss= | awk '{ sum += $1 } END { print "Resident Set Size: " sum/1024 " MiB" }')
    MEM=$(top -l 1 -s 0 | grep PhysMem | awk -F ': ' '{print $2}') 
elif [[ $OSTYPE =~ "linux" ]]; then
	LOAD=$(uptime | awk 'BEGIN{FS="average:"}{print $2}')
	CPU=$(cat /proc/cpuinfo | grep '^model name' | uniq | awk -F ": " '{print $2}')
#	PHYSPROC=`grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l`
    PROCORES=`grep 'cpu cores' /proc/cpuinfo | uniq | awk 'BEGIN{FS=": "}{print $2}'`
	VIRTPROC=`grep ^processor /proc/cpuinfo | wc -l`
	FLAGS=`cat /proc/cpuinfo | grep 'flags' | uniq | awk 'BEGIN{FS=": "}{print $2}'`
	MEM=$(free -th | grep Mem: | awk '{print $3" used (of "$2"), "$3" unused. "}')
else
    echo "ERROR: Unknown \$OSTYPE!"
fi

echo "------------------"
echo "System Information"
echo "------------------"
echo "${b}Current date:${n} $CURRENT"
echo "${b}Hostname:${n} $(hostname)"
echo "  ${b}Uptime:${n} $UP"
echo "  ${b}Load average:${n}${LOAD}"
echo "  ${b}Kernel:${n} $PLATFORM"
echo "${b}CPU Information:${n} $CPU"
echo "  ${b}Processor Cores:${n} $PROCORES"
echo "  ${b}Virtual Processors:${n} $VIRTPROC"
#echo "  ${b}CPU Flags:${n} $FLAGS"
echo "${b}Memory Information:${n} $MEM"
#echo "  Memory stats:"

#EOF
