#!/bin/bash

# date: 04/19/2009
# author: Chad Mayfield (http://www.chadmayfield.com/)
# license: gpl v3 (http://www.gnu.org/licenses/gpl-3.0.txt)

# I have to mount ISO files at work all the time and quite often
# at home as well.  I created this utility to automate the process
# of creating a mount point and mounting the ISO.

#+-- Check to make sure that user is root
if [ "$(id -u)" != "0" ]; then
	echo "ERROR: You must be root to run this utility!"
    exit 1;
fi

usage() {
	echo "Usage: $0 <mount|unmount> </full/path/to/isofile>"
	exit 1;
}

#+-- Check arguments, if none print usage
if [ $# -eq 0 ]; then
	usage
fi

isonamewithpath=$2		#+-- Save the full path of the iso
isonameonly=${2##*/}	#+-- Strip off the path from the iso
mntdirname=`echo $isonameonly | sed -e 's/\.[a-zA-Z0-9_-]\+$//'`
ismounted=`cat /proc/mounts | grep -c $mntdirname`

mountiso() {
	#+-- Check if /mnt/$dirname is already there
	if [ ! -d /mnt/$mntdirname ]; then
		mkdir -p /mnt/$mntdirname && echo "SUCCESS: Created directory: /mnt/$mntdirname"
	fi

	#+-- Check if ISO is already mounted, if not mount it
	if [ $ismounted -ge  1 ]; then
		echo "ERROR: File $isonamewithpath already mounted!"
	else
		mount -o loop $isonamepath /mnt/$mntdirname && echo "SUCCESS: File $isonameonly mounted"
		#cd /mnt/$dirname
	fi
}

unmountiso() {
	if [  -ge  1 ]; then
		umount /mnt/$mntdirname 
		echo "Unmounted $isonamepath" 
		rm -rf /mnt/$mntdirname
		echo "Removed /mnt/$mntdirname"
	else
		echo "ERROR: File $isonamepath is not mounted"
		exit 1;
	fi
}

if [ $# -eq 2 ]; then
	if [ "$1" = "mount" ]; then
		mountiso
	elif [ "$1" = "unmount" ]; then
		unmountiso
	else
		echo "ERROR: Invalid option specified: $1"
	fi
else
	usage
fi

