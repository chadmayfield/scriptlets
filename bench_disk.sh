#!/bin/bash

# bench_disk.sh - a rough disk benchmark tool using dd (bonnie, ioping)

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

path=$1
#log_file=/var/log/diskbench.log
tmp_file=tempfile
dev_in=/dev/zero
dev_out=/dev/null    # where to write it
block_size=1M        # block size to write
count=1024           # number of blocks to write

# verify we have correct args
if [ $# -ne 1 ]; then
    echo "Please specify a path to test!"
    exit 1
fi

# verify that our path that exists
if [ ! -d $path ]; then
    echo "Path does not exist: $path"
    exit 1
fi

# don't mess with permissions, just switch to root
if [ $UID -ne 0 ]; then
    echo "Must be run as root, please enter your password:"
    sudo -ik $0 $@
    exit 5
fi

# TODO: added arg for size of tempfile and iterations
# TODO: check for disk space available so we kill anything

##### functions start #####

# TODO: add logging to file and console for historical data
#log() {
#    echo "$(date): $@" >> $logfile
#}

# dd benchmarking commands (in part) adapted from the archlinux wiki
# https://wiki.archlinux.org/index.php/SSD_Benchmarking#Using_dd

do_seq_write() {
    # sequential write
    echo -n "  writing..."
    dd if=$dev_in of=$tmp_file bs=1M count=1024 conv=fdatasync,notrunc &>/tmp/$$
    seq_write=$(grep -v records /tmp/$$)
    w_speed=$(grep -v records /tmp/$$ | awk '{print $8" "$9 }')
    w_size=$(grep -v records /tmp/$$ | awk '{print $3" "$4}' | tr -d '()')
    w_time=$(grep -v records /tmp/$$ | awk '{print $6" "$7}' | tr -d ',' )
}

do_flush() {
    # flush cache
    echo -n "  flushing cache..."
    echo 3 > /proc/sys/vm/drop_caches
}

do_seq_read() {
    # sequential read
    echo -n "  reading..."
    dd if=$tmp_file of=$dev_out bs=$block_size count=$count &> /tmp/$$
    seq_read=$(grep -v records /tmp/$$)
    r_speed=$(grep -v records /tmp/$$ | awk '{print $8" "$9 }')
    r_size=$(grep -v records /tmp/$$ | awk '{print $3" "$4}' | tr -d '()')
    r_time=$(grep -v records /tmp/$$ | awk '{print $6" "$7}' | tr -d ',' )
}

do_cached_read() {
    # cached sequential read
    echo -n "  reading (cached)..."
    dd if=$tmp_file of=$dev_out bs=$block_size count=$count &> /tmp/$$
    cached_read=$(grep -v records /tmp/$$)
    rc_speed=$(grep -v records /tmp/$$ | awk '{print $8" "$9 }')
    rc_size=$(grep -v records /tmp/$$ | awk '{print $3" "$4}' | tr -d '()')
    rc_time=$(grep -v records /tmp/$$ | awk '{print $6" "$7}' | tr -d ',' )
}

cleanup() {
    # remove test file
    rm -f $tmp_file /tmp/$$
    sleep 2
}

echo "beginning dd tests:"
for i in do_seq_write do_flush do_seq_read do_cached_read
do
    $i
    sleep 1
    echo "done"
done

# TODO: add ioping and bonnie++ tests
#echo "beginning bonnie++ tests:"
#echo "  coming soon"

cleanup

echo "dd results:"

# raw dd output
#echo " "
#echo "Sequential write: $seq_write"
#echo "Sequential read : $seq_read"
#echo "Cached read     : $cached_read"
#echo " "

# prettier output
printf "  write   $w_speed \t($w_size in $w_time)\n"
printf "  read    $r_speed \t($r_size in $r_time)\n"
printf "  cached  $rc_speed \t($rc_size in $rc_time)\n"

#EOF
