# scriptlets

A bunch of sciptlets to automate tasks that I do often.

Directories;
* **diceare/** - mirror of the famous diceware lists that can be easily downloaded for use with other scripts
* **experimental/** - contains test script or expirements that have been written while writing other scripts, may or may not work. Not meant to be used, just kept around as reference or fun.
* **old_n_deprecated/** - old, broken, or otherwise deprecated scripts/apps that have been written and are broken or EOL. 

### bench_disk.sh
a rough disk benchmarking utiltiy using dd (use tee to add to logfile and keep historical data)

```
chad@myhost:~$ sudo ./bench_disk.sh /tmp/ | tee -a bench_disk_20150709_2204.log
[sudo] password for chad:
beginning dd tests:
  writing...done
  flushing cache...done
  reading...done
  reading (cached)...done
dd results:
  path    /tmp/
  write   280 MB/s      (1.1 GB in 3.83191 s)
  read    311 MB/s      (1.1 GB in 3.45511 s)
  cached  293 MB/s      (1.1 GB in 3.6592 s)
```

### bench_net.sh
a rough bandwidth benchmarking utility using wget (use tee to add to logfile and keep historical data)

```
chad@myhost:~$ ./bench_net.sh | tee -a bench_net_20150709_2205.log
beginning speed/latency tests...
  Speed from SoftLayer, DC USA        :  7.74MB/s        (77.392 ms latency)
  Speed from Edis, Frankfurt DE       :  2.31MB/s        (154.037 ms latency)
  Speed from Bahnhof, Sundsvall SE    :  7.40MB/s        (180.912 ms latency)
  Speed from Linode, Atlanta GA USA   :  26.4MB/s        (59.380 ms latency)
  Speed from Leaseweb, Haarlem NL     :  198MB/s         (9.869 ms latency)
  Speed from DigitalOCean, NY USA     :  4.89MB/s        (73.899 ms latency)
  Speed from CacheFly CDN Network     :  55.9MB/s        (0.512 ms latency)
  Speed from Linode, Singapore        :  11.8MB/s        (184.932 ms latency)
  Speed from Linode, Dallas TX USA    :  24.1MB/s        (45.719 ms latency)
  Speed from Linode, Tokyo JP         :  18.3MB/s        (101.913 ms latency)
  Speed from SoftLayer, SJ CA USA     :  48.0MB/s        (8.217 ms latency)
done
```

### checksum.sh
checksum (md5/sha1) all regular files under a directory tree
```
chad@myhost:~$ ./checksum.sh sha1 /Users/chad/Books/
chad@myhost:~$ head -n5 ~/checksums.3075.txt 
63902c99e287b05463f46be3551aa37260cd5665  /Users/chad/Books//Docker_Cookbook.pdf
dff0c59900275673c29fde9fc97de390c3edd2c3  /Users/chad/Books//Docker_in_Practice.pdf
52332d0a159305d3c55deaacfda9f02fd48b80c2  /Users/chad/Books//Unix_Power_Tools_Third_Edition.pdf
8b09f063a6db3e73424c9af678f5256bc5b1f562  /Users/chad/Books//Using_Docker.pdf
8fc938c3e5b73daad3cbcdb75c06653e957db854  /Users/chad/Books//Introducing_Go.pdf
```

### ck_raid.sh
Gather info about PERC (specifically the 6/i and other LSI based cards that use MegaCli) and display in a pretty format. Also use the monitor function, designed to be called from cron, to monitor the array health and alert an email on errors.

```
[root@myhost ~]# ./ck_raid.sh 
ERROR: Unknown option! Please change the option and try again.
  e.g. ./ck_raid.sh <info|monitor>
[root@myhost ~]# ./ck_raid.sh info
Product Name           PERC 6/i Adapter
Serial No              1122334455667788
FW Package Build       6.3.1-0003
FW Version             1.22.32-1371
BIOS Version           2.04.00
Host Interface         PCIE
Memory Size            256MB
Supported Drives       SAS, SATA
Virtual Drives         1
  Degraded             0
  Offline              0
Physical Devices       4
  Disks                4
  Critical Disks       0
  Failed Disks         0
Virtual Drive Info
  RAID Level           Primary-5, Secondary-0, RAID Level Qualifier-3
  Size                 4.091 TB
  Sector Size          512
  Strip Size           64 KB
  Number Of Drives     4
  Span Depth           1
Drive Status           OPTIMAL
  Slot Number 0        Online, Spun Up      9VS12A34ST1500DM003-9YN16G
  Slot Number 1        Online, Spun Up      9VS12B34ST1500DM003-9YN16G
  Slot Number 2        Online, Spun Up      9VS12C34ST1500DM003-9YN16G
  Slot Number 3        Online, Spun Up      9VS12D34ST1500DM003-9YN16G
[root@myhost ~]# ./ck_raid.sh monitor
STATE:  Degraded
ERROR:  1 Disks Degraded
ERROR:  1 Disks Offline
ERROR:  0 Critical Disks
ERROR:  0 Failed Disks
```

### entropy_ck.sh
calculate the Shannon entropy of a string (if using with a password use a space before the command execution to override storing it in the history buffer"

```
chad@myhost:~$  ./entropy_ck.sh "Tr0ub4dor&3"
passwd length:   11
entropy/char:    3.27761343682
actual entropy:  36.053747805 bits
chad@myhost:~$  ./entropy_ck.sh "correcthorsebatterystaple"
passwd length:   25
entropy/char:    3.36385618977
actual entropy:  84.0964047444 bits
```

### chkrootkit.sh
run chkrootkit then log & email results (chkrootkit is required)

### convert_rhel2centos.sh
convert RHEL to CentOS in less that 100 lines of bash! This will take an install of RHEL 6 or 7 and convert it to CentOS 6 or 7, respectively.  (NOTE: This is pretty 'hacky' so I wouldn't use the machine in production.)

A gist of the script output can be seen here: https://gist.github.com/chadmayfield/b7816a17ff665a6ddbcc8b5e7f64703d

### measure_latency.sh
a quick and dirty latency measurement tool

NOTE: This is just a quick tool to use so you don't have to bust out of the terminal, if you want historic views, use smokeping.

```
chad@macbookpro:~$ ./measure_latency.sh yahoo.com
ERROR: You must supply a hostname/IP to measure & a packet count!
  e.g. ./measure_latency.sh <hostname/ip> <count>
chad@macbookpro:~$ ./measure_latency.sh 8.8.4.4 10
latency to 8.8.4.4 with 10 packets is: 74.735 ms
chad@macbookpro:~$ ./measure_latency.sh msn.com 10
latency measurement failed: 100.0% packet loss

-- or on linux --

ubuntu@ubuntu-xenial:~$ ./measure_latency.sh 8.8.8.8 10
latency to 8.8.8.8 with 10 packets is: 203.783 ms
ubuntu@ubuntu-xenial:~$ ./measure_latency.sh msn.com 10
latency measurement failed: 100% packet loss
```

### randomize_mac.sh
randomize mac addresses on macOS and Linux. This will help circumvent free wifi time limits in coffee shops and such. (This was actually an experiment until I begain using it more and more. I know about and have used machanger and spoofMAC, but I wanted to use something I wrote!)
```
macbookpro:~ $ ifconfig en0 | grep ether
	ether 87:41:13:1e:e3:ab 
macbookpro:~ $ sudo ./randomize_mac.sh 
Default Interface:   en0
Default MAC Address: 87:41:13:1e:e3:ab
Random MAC Address:  00:50:56:04:a3:f1
Succeessfully changed MAC!
macbookpro:~ $ ifconfig en0 | grep ether
	ether 00:50:56:04:a3:f1 
macbookpro:~ $ sudo ./randomize_mac.sh --revert
Original MAC address found: 87:41:13:1e:e3:ab
Reverting it back...
Succeessfully changed MAC!
macbookpro:~ $ ifconfig en0 | grep ether
	ether 87:41:13:1e:e3:ab
```


### remove_spaces.sh
removes spaces in file names under path

```
chad@myhost:~$ ./remove_spaces.sh test
test/Docker Cookbook.pdf -> test/Docker.Cookbook.pdf
test/Unix Power Tools Third Edition.pdf -> test/Unix.Power.Tools.Third.Edition.pdf
test/Using Docker.pdf -> test/Using.Docker.pdf
test/Version Control with Git Second Edition.pdf -> test/Version.Control.with.Git.Second.Edition.pdf
```

### sysinfo.sh
show system information for various oses, including load, uptime, cpu information, docker version and running containers, and network information. When used with the `--connections` option it will show all established connections with hostname if possible.

(As of now works with macOS Sierra, RHEL, CentOS, Ubuntu, Debian)

Apple macOS Sierra
```
macbookpro:~ $ ./sysinfo.sh --connections 
------------------------------------------------------------------------
Current Date:        Fri Apr  7 18:59:43 MDT 2017
Hostname:            macbookpro.local
OS:                  Mac OS X 10.12.4 (16E195)
Kernel:              Darwin 16.5.0
HW Version:          MacBook Pro (13-inch, 2016, Two Thunderbolt 3 ports)
HW Serial:           8SF79S7DA9SF
HW UUID:             6EB1244E-BC1F-323A-9724-5AB7B382D921
Uptime:              21:01 hours
Load Average:        1.34 1.37 1.28
Processor:           Intel(R) Core(TM) i5-6360U CPU @ 2.00GHz
Core Count:          2
Virtual Cores:       4
Total Memory:        8.00 gigabytes
Memory Used:         7956M used (1864M wired), 234M unused.
Internal IP:         192.168.110.213 (Tx/Rx: 94544383 bytes)
External IP:         166.72.33.98 (166-72-33-98.xmission.com)
Docker Version:      17.03.1-ce
Containers:          CONTAINER ID       NAME 
                     b22c0ef58f62	confident_bose
                     50b7deb5898f	loving_torvalds
Current Connections: 192.168.110.213
                     173.194.196.109 (ix-in-f109.1e100.net.)
                     34.192.55.128 (ec2-34-192-55-128.compute-1.amazonaws.com.)
                     40.97.150.242
                     52.2.45.245 (ec2-52-2-45-245.compute-1.amazonaws.com.)
                     54.84.82.15 (ec2-54-84-82-15.compute-1.amazonaws.com.)
                     65.52.108.204 (msnbot-65-52-108-204.search.msn.com.)
                     74.125.202.108 (io-in-f108.1e100.net.)
------------------------------------------------------------------------
``` 

Red Hat Enterprise Linux 7.3
```
[chad@fileserver ~]$ ./sysinfo.sh --connections 
------------------------------------------------------------------------
Current Date:        Fri Apr  7 18:57:35 MDT 2017
Hostname:            fileserver.local
OS:                  Red Hat Enterprise Linux Server release 7.3 (Maipo)
Kernel:              Linux 3.10.0-514.10.2.el7.x86_64
HW Version:          Dell Inc. PowerEdge T20
HW Serial:           None
HW UUID:             4C4C6544-0082-3610-8056-B4C04FY05A21
Uptime:              29 days hours
Load Average:        0.00, 0.02, 0.05
Processor:           Intel(R) Xeon(R) CPU E3-1245 v3 @ 3.40GHz
Core Count:          4
Virtual Cores:       8
Total Memory:        23.30 gigabytes
Memory Used:         1.2G used (of 23G), 6.5G unused. 
Internal IP:         192.168.110.30 (Tx/Rx: 121.3 GiB)
External IP:         166.72.33.98 (166-72-33-98.xmission.com)
Docker Version:      1.12.6
Containers:          CONTAINER ID       NAME 
                     d4199824e0a5	plex
                     1b92338bbb80	unifi
Current Connections: 192.168.110.3
                     52.41.5.6 (ec2-52-41-5-6.us-west-2.compute.amazonaws.com.)
                     52.41.5.6 (ec2-52-41-5-6.us-west-2.compute.amazonaws.com.)
                     52.41.5.6 (ec2-52-41-5-6.us-west-2.compute.amazonaws.com.)
                     192.168.110.213
------------------------------------------------------------------------
```


### update_myrepos.sh
an automated update script that iterates through all subdirectories (only one deep) under the current tree and pull any changes to the git repos there. assumes ssh is used (not https) to pull/push repos.

```
chad@myhost:~$ ./update_myrepos.sh 
Found repo: git@github.com:chadmayfield/chadmayfield.github.io.git
Pulling latest changes...
Already up-to-date.
Found repo: git@github.com:chadmayfield/compliance_checks.git
Pulling latest changes...
Already up-to-date.
Found repo: git@github.com:chadmayfield/scriptlets.git
Pulling latest changes...
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
From github.com:chadmayfield/scriptlets
   fa418b1..66db9c9  master     -> origin/master
Updating fa418b1..66db9c9
Fast-forward
 README.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

### vagrant_update_boxes.sh
a quick update script for all of my vagrant boxes

```
chad@myhost:~$ ./vagrant_update_boxes.sh 
Found Vagrantfile at: ./centos_7/Vagrantfile
Updating box: "centos/7"
==> default: Checking for updates to 'centos/7'
    default: Latest installed version: 1702.01
    default: Version constraints: 
    default: Provider: virtualbox
==> default: Box 'centos/7' (v1702.01) is running the latest version.
Found Vagrantfile at: ./rancher/os-vagrant/Vagrantfile
Updating box: "rancherio/rancheros"
==> rancher-01: Checking for updates to 'rancherio/rancheros'
    rancher-01: Latest installed version: 0.4.3
    rancher-01: Version constraints: >=0.4.1
    rancher-01: Provider: virtualbox
==> rancher-01: Box 'rancherio/rancheros' (v0.4.3) is running the latest version.
```
