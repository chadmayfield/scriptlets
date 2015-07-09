#!/bin/bash

# bench_net.sh - a quick and dirty script to test a server's bandwidth speed

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

options="-O /dev/null"

declare -A array

array["CacheFly  "]="http://cachefly.cachefly.net/100mb.test"
array["Linode, CA"]="http://speedtest.fremont.linode.com/100MB-fremont.bin"
array["Linode, TX"]="http://speedtest.dallas.linode.com/100MB-dallas.bin"
array["Linode, GA"]="http://speedtest.atlanta.linode.com/100MB-atlanta.bin"

for i in "${!array[@]}"
do
    url=${array[$i]}
    echo -ne "Speed from $i : \t"
    wget $options $url 2>&1 | \
     awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}'
done

#EOF
