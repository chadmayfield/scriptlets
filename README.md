# scriptlets

A bunch of sciptlets to automate tasks that I do often.  (The experimental/ directory is just some fun scripts that are not finished that I just wanna do for fun.)

* **bench_disk.sh** - a rough disk benchmarking utiltiy using dd (use tee to add to logfile and keep historical data)

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

* **bench_net.sh** - a rough bandwidth benchmarking utility using wget (use tee to add to logfile and keep historical data)

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

* **checksum.sh** - checksum (md5/sha1) all regular files under a directory tree
```
chad@myhost:~$ ./checksum.sh sha1 /Users/chad/Books/
chad@myhost:~$ head -n5 ~/checksums.3075.txt 
63902c99e287b05463f46be3551aa37260cd5665  /Users/chad/Books//Docker_Cookbook.pdf
dff0c59900275673c29fde9fc97de390c3edd2c3  /Users/chad/Books//Docker_in_Practice.pdf
52332d0a159305d3c55deaacfda9f02fd48b80c2  /Users/chad/Books//Unix_Power_Tools_Third_Edition.pdf
8b09f063a6db3e73424c9af678f5256bc5b1f562  /Users/chad/Books//Using_Docker.pdf
8fc938c3e5b73daad3cbcdb75c06653e957db854  /Users/chad/Books//Introducing_Go.pdf
```

* **entropy_ck.sh** - calculate the Shannon entropy of a string (if using with a password use a space before the command execution to override storing it in the history buffer"

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

* **chkrootkit.sh** - run chkrootkit then log & email results (chkrootkit is required)

* **randomize_mac.sh** - randomize mac addresses on macOS and Linux. This will help circumvent free wifi time limits in coffee shops and such. (This was actually an experiment until I begain using it more and more. I know about and have used machanger and spoofMAC, but I wanted to use something I wrote!)
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


* **remove_spaces.sh** - removes spaces in file names under path

```
chad@myhost:~$ ./remove_spaces.sh test
test/Docker Cookbook.pdf -> test/Docker.Cookbook.pdf
test/Unix Power Tools Third Edition.pdf -> test/Unix.Power.Tools.Third.Edition.pdf
test/Using Docker.pdf -> test/Using.Docker.pdf
test/Version Control with Git Second Edition.pdf -> test/Version.Control.with.Git.Second.Edition.pdf
```

* **sysinfo.sh** - show system information for various oses, including load, uptime, cpu information, docker version and running containers, and network information. When used with the `--connections` option it will show all established connections with hostname if possible.

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


* **update_myrepos.sh** - an automated update script that iterates through all subdirectories (only one deep) under the current tree and pull any changes to the git repos there. assumes ssh is used (not https) to pull/push repos.

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

* **userinfo.php** - simple userinfo script from php, formatted friendly for getting information via the terminal.  can be called very easily;

> curl -s example.com/userinfo.php | awk '/REMOTE_ADDR/ {print $2}'

```
USER INFORMATION
---------------------------------------
HOME                           /var/www
TERM                           linux
SHELL                          /bin/bash
PHP_FCGI_CHILDREN              6
HTTP_ACCEPT_LANGUAGE           en-US,en;q=0.8
HTTP_ACCEPT_ENCODING           gzip, deflate, sdch
HTTP_DNT                       1
HTTP_ACCEPT                    text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
HTTP_USER_AGENT                Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36
HTTP_UPGRADE_INSECURE_REQUESTS 1
HTTP_CACHE_CONTROL             max-age=0
HTTP_CONNECTION                keep-alive
HTTP_HOST                      server.example.com
REDIRECT_STATUS                200
HTTPS                          
SERVER_NAME                    www.example.com
SERVER_PORT                    80
SERVER_ADDR                    140.216.83.12
REMOTE_PORT                    51642
REMOTE_ADDR                    170.172.91.68
SERVER_SOFTWARE                nginx/1.2.1
GATEWAY_INTERFACE              CGI/1.1
SERVER_PROTOCOL                HTTP/1.1
DOCUMENT_URI                   /userinfo.php
REQUEST_URI                    /userinfo.php
SCRIPT_NAME                    /userinfo.php
CONTENT_LENGTH                 
CONTENT_TYPE                   
REQUEST_METHOD                 GET
QUERY_STRING                   
FCGI_ROLE                      RESPONDER
PHP_SELF                       /userinfo.php
REQUEST_TIME_FLOAT             1491962862.7097
REQUEST_TIME                   1491962862
```

* **vagrant_update_boxes.sh** - a quick update script for all of my vagrant boxes

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
