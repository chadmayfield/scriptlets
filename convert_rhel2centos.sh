#!/bin/bash

# convert_rhel2centos.sh - convert an installed RHEL system to a CentOS system

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# NOTE: This is pretty much useless now, since Red Hat allows one developer
#       license to use at no cost for non-production use (for developers) which
#       means you can get updates from RH and don't have to convert to update.
#       BE CAREFUL THIS IS A ONE WAY STREET! http://red.ht/2ooh1oG

# must be root
if [ $UID -ne 0 ]; then
    echo "ERROR: You must be root to run this script!"
    exit 1
fi

# check redhat release (looking for 6 or 7)
version=$(grep VERSION_ID /etc/os-release | awk -F '"' '{print $2}')
if [[ $version =~ "6." ]]; then
    version=6
elif [[ $version =~ "7." ]]; then
    version=7
else
    echo "ERROR: Unknown version, $version! Can't proceed."
    exit 2
fi

# check the rhel packages installed
while read line
do
    # these are dependencies of rhnlib (removed with yum) so skip them
    if [[ $line =~ (rhn-(client-tools|check|setup)) ]]; then
        break
    fi

    # remove some packages with yum (resolve deps)
    if [[ $line =~ (rhnlib|redhat-support*) ]]; then
        echo "Removing with yum: $line"
        yum remove -y $line
    else
        # otherwise manually remove the rest: redhat-(release-server|logos)|
        #rhn-(client-tools|check|setup)|rhnsd|yum-rhn-plugin
        echo "Removing with RPM: $line"
        rpm -e --nodeps $line
    fi
done < <(rpm -qa --qf "%{NAME}\n" | grep -iE 'rhn|redhat')

# check if they were all removed
if [ $(rpm -qa | grep -iE 'rhn|redhat' | wc -l) -eq 0 ]; then
    echo "SUCCESS: Removed Red Hat related packages!"
else
    echo "ERROR: Unable to remove some Red Hat packages! Please run the"
    echo "following command and remove them manually."
    echo "rpm -qa | grep -iE 'rhn|redhat'"
    exit 3
fi

# cleanup some directories (otherwise will get cpio errors on centos)
rm -rf /usr/share/doc/redhat-release/
rm -rf /usr/share/redhat-release/

mkdir -p /tmp/centos && cd /tmp/centos/
url="http://mirror.centos.org/centos/$version/os/x86_64/"

# download GPG-key
curl -O "${url}/RPM-GPG-KEY-CentOS-${version}"

# download packages
while read line
do
    echo "Downloading: $line"
    curl -O "${url}Packages/${line}"
done < <(curl -s http://mirror.centos.org/centos/$version/os/x86_64/Packages/ | grep -E 'yum-[[:digit:]]|yum-plugin-fastestmirror|centos-(logos-|release-)' | awk -F '"' '{print $8}' | grep -v PackageKit)

# install the GPG-key
rpm --import RPM-GPG-KEY-CentOS-${version}
# install the packages
rpm -Uvh *.rpm
# clean up
yum clean all
# upgrade
yum upgrade -y
# update GRUB2-config with new info
grub2-mkconfig -o /boot/grub2/grub.cfg

echo -n "Success! We'll reboot in "
count=20
while [ $count -gt 0 ]; do
    echo -n "$count "
    let count-=1
    sleep 1
done

# reboot (init 6)
reboot

#EOF
