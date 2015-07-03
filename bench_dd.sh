#!/bin/bash

# bench_dd.sh - a very rough disk benchmark tool using dd

tmp_file=tempfile
dev_in=/dev/zero     # 
dev_out=/dev/null    # where to write it
block_size=1M        # block size to write
count=1024           # number of blocks to write

# adapted in part from the Arch Linux wiki on SSD benchmarking
# https://wiki.archlinux.org/index.php/SSD_Benchmarking#Using_dd

# check args
if [ $# -eq 0 ]; then
    echo "please specify the path"
fi

# functions start
log() {
    echo "$(date): $@" >> $logfile
}


# require dir/path, if not use current dir
## check permissions on target dir

# check for disk space available


# sequential write
dd if=$dev_in of=$tmpfile bs=1M count=1024 conv=fdatasync,notrunc
# flush cache
echo 3 > /proc/sys/vm/drop_caches
# sequential read
dd if=$tempfile of=$dev_out bs=$block_size count=$count
# cached sequential read
dd if=$tempfile of=$dev_out bs=$block_size count=$count
# remove test file
rm -f $tempfile




# sequential write
dd if=/dev/zero of=tempfile bs=1M count=1024 conv=fdatasync,notrunc
# flush cache
echo 3 > /proc/sys/vm/drop_caches
# sequential read
dd if=tempfile of=/dev/null bs=1M count=1024
# cached sequential read
dd if=tempfile of=/dev/null bs=1M count=1024
# remove test file
rm -f tempfile


#EOF
