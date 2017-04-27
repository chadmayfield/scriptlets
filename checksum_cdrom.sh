#!/bin/bash

# checksum_cdrom.sh - get checksum of burnt cd/dvd rom

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# TODO:
#   + make work when more than one drive exists
#   + make work on macos

if [ $# -ne 1 ]; then
    echo "ERROR: You must supply an iso file to compare!"
    echo "  e.g. $0 /path/to/discimage.iso"
    exit 1
fi

bin=(volname wodim md5sum sha1sum)
for i in ${bin[@]}
do
    command -v $i >/dev/null 2>&1 || { \
        echo >&2 "ERROR: You must install $i to continue!"; exit 1; }
done

iso=$1
algo=sha1sum
#algo=md5sum
# get the device name, unless grep fails exit
dev="/dev/$(grep "drive name" /proc/sys/dev/cdrom/info | awk '{print $NF}'; exit ${PIPESTATUS[0]})"
# is there a disc in the tray?
exists=$(volname $dev &>/dev/null; echo $?)
# get drive name, but requires lock
#info=$(wodim -prcap 2> /dev/null | grep -E 'Vendor_|Ident|Revi' | awk -F "'" '{print$2}' | tr '\n' ' ')

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "ERROR: No CD/DVD device not found!"
    exit 1
elif [ $exists -ne 0 ]; then
    echo "ERROR: No disc mounted! Please insert a disc and try again."
    exit 1
fi

#echo "Found drive: $info"
echo "Found disc in $dev: $(volname $dev)"
echo -n "Beginning checksum..."
cksum_iso=$($algo $iso | awk '{print $1}')
cksum_cdr=$(dd if=${dev} &> /dev/null | head -c $(stat --format=%s $iso) | $algo | awk '{print $1}')

if [ "$cksum_iso" != "$cksum_cdr" ]; then
    echo "done!"
    echo "ERROR: Checksums do not match!"
    echo "  Checksum of ${iso##*/}: $cksum_iso"
    echo "  Checksum of disc in $dev: $cksum_cdr"
else
    echo "done!"
    echo "Checksums match! $cksum_iso"
fi

#EOF
