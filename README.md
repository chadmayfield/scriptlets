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

* **remove_spaces.sh** - removes spaces in file names under path

```
chad@myhost:~$ ./remove_spaces.sh test
test/Docker Cookbook.pdf -> test/Docker.Cookbook.pdf
test/Unix Power Tools Third Edition.pdf -> test/Unix.Power.Tools.Third.Edition.pdf
test/Using Docker.pdf -> test/Using.Docker.pdf
test/Version Control with Git Second Edition.pdf -> test/Version.Control.with.Git.Second.Edition.pdf
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
Already up-to-date.
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
