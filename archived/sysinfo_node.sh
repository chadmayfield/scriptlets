#~/bin/bash

# date: 04/19/2009
# author: chadfu (http://www.chadmayfield.com/)
# license: gpl v3 (http://www.gnu.org/licenses/gpl-3.0.txt)

# 
#

local_hostname=`hostname`
proc_type=`grep vendor_id /proc/cpuinfo | awk 'BEGIN { FS=": | " } { print $2 }' | head -n1`
proc_model=`grep model\ name /proc/cpuinfo | awk 'BEGIN { FS=": |  " } { print $2 }' | head -n1`
proc_speed=`grep model\ name /proc/cpuinfo | awk 'BEGIN { FS="@ " } { print $2 }' | head -n1`
proc_phy_cores=`grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l`
proc_virt_cores=`grep ^processor /proc/cpuinfo | wc -l`
proc_ht=`grep flags /proc/cpuinfo | grep -c ht`
mem_ttl=`free -m | grep Mem: | awk '$7 {print $2}'`
disk_size_ttl=``
disk_config=``

echo "========================="
echo "Hostname: $HOSTNAME"
echo "---"
echo "Processor Type: $proc_type $proc_model $proc_speed"
echo "Physical Processors: $proc_phy_cores"
echo "Virtual Cores: $proc_virt_cores"
if [ $proc_ht -ge 1 ]; then
        echo "Hyper-Threading *is* supported."
else
        echo "Hyper-Threading *is not* supported."
fi
echo "---"
echo "Total Memory Installed, $mem_ttl MB"
echo "---"
echo "Number of Hard Disks: $()"
echo "Total Hard Disk Size: "
echo "Hard Drive Configuration: "
echo "========================="
