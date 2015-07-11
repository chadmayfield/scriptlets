#!/bin/bash

# bench_net.sh - a quick and dirty script to test a server's bandwidth speed

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

# limitations:
#   - unable to test ipv6
#   - does not work well with old version of wget
#   - only uses 100mb files (bad at testing gigabit speed)
# TODO:
#   - parameterize to test by region
#   - add ipv6 support

tmpfile="/tmp/$0.$$"
options="-O /dev/null"

declare -A array

array["CacheFly CDN Network  "]="http://cachefly.cachefly.net/100mb.test"

#### NORTH AMERICA
array["Linode, Fremont CA USA"]="http://speedtest.fremont.linode.com/100MB-fremont.bin"
array["SoftLayer, SJ CA USA  "]="http://speedtest.sjc01.softlayer.com/downloads/test100.zip"
array["SoftLayer, SEA WA USA "]="http://speedtest.sea01.softlayer.com/downloads/test100.zip"
array["Linode, Dallas TX USA "]="http://speedtest.dallas.linode.com/100MB-dallas.bin"
array["Linode, Atlanta GA USA"]="http://speedtest.atlanta.linode.com/100MB-atlanta.bin"
array["DigitalOcean, NY USA  "]="http://speedtest-nyc1.digitalocean.com/100mb.test"
array["Linode, Newark NJ USA "]="http://speedtest.newark.linode.com/100MB-newark.bin"
array["SoftLayer, DC USA     "]="http://speedtest.wdc01.softlayer.com/downloads/test100.zip"
array["OVH, Beauharnois QC CA"]="http://bhs.proof.ovh.net/files/100Mb.dat"

#### EUROPE
#array["Edis, Frankfurt DE    "]="http://de.edis.at/100MB.test"
#array["Edis, Warsaw PL       "]="http://pl.edis.at/100MB.test"
#array["DigitalOcean, AMS NL  "]="http://speedtest-ams1.digitalocean.com/100mb.test"
#array["Leaseweb, Haarlem NL  "]="http://mirror.leaseweb.com/speedtest/100mb.bin"
#array["Bahnhof, Sundsvall SE "]="http://speedtest.bahnhof.se/100M.zip"
#array["DigitalOcean, LON EN  "]="http://ipv4.speedtest-lon1.digitalocean.com/100mb.test"
#array["DigitalOcean, PAR FR  "]="http://speedtest-fra1.digitalocean.com/100mb.test"
#array["Edis, Bucharest RO    "]="http://ro.edis.at/100MB.test"
#array["Edis, Hafnarfjordur IS"]="http://is.edis.at/100MB.test"
#array["Edis, Moscow RU       "]="http://ru.edis.at/100MB.test"
#array["Edis, Tel Aviv IL     "]="http://il.edis.at/100MB.test"

#### SOUTH AMERICA
#array["Edis, Vina del Mar CL "]="http://cl.edis.at/100MB.test"

#### ASIA/PACIFICA
#array["Linode, Tokyo JP      "]="http://speedtest.tokyo.linode.com/100MB-tokyo.bin"
#array["Linode, Singapore     "]="http://speedtest.singapore.linode.com/100MB-singapore.bin"
#array["SoftLayer, Singapore  "]="http://speedtest.sng01.softlayer.com/downloads/test100.zip"
#array["Edis, NwTerritories HK"]="http://hk.edis.at/100MB.test"

echo "beginning speed/latency tests..."
echo "  start time: $(date)"

for i in "${!array[@]}"
do
    # run wget as out speedtest & save the output
    wget $options ${array[$i]} &> $tmpfile
    speed=$(awk '/\/dev\/null/ {s=$3 $4} END {gsub(/\(|\)/,"",s); print s}' $tmpfile)
    
    # find a quick avg latency (does work with wget >1.13)
    ip=$(awk '/connected/ {print $4}' $tmpfile | awk -F"|" '{print $2}')
    cmd=$(ping -q -c 20 -i 0.2 -w 5 $ip | \
          awk -F "/" '/rtt/ {print $5 " ms latency"}')

    echo -ne "  Speed from $i : ${speed}\t(${cmd})\n"
done

rm -f $tmpfile
echo "  end time: $(date)"
echo "done"

#EOF
