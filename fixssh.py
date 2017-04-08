#!/usr/bin/env python

# fixssh.py - fix bad ssh keys from server OVER-deployment, a quick hack and
#             useless re-engineering of 'ssh-keygen -R <hostname>'

# NOTE: Reinvent the wheel, yup I did it. I fequently deploy a lot of servers
# which are DHCP/DNS'd so when the SSH keys regenerate I always used to get key
# errors, so I have this gem.... before I discovered 'ssh-keygen -R <hostname>'

import sys, os

def main():
    # print usage if no args are given
    sname = os.path.basename(sys.argv[0])
    if len(sys.argv) == 1:
        print "Usage: " + sname  + " <hostname|ip address>"
        sys.exit()

    # assign first arg as hostname
    for arg in sys.argv[1:]:
        h = arg

    # define files we'll work on
    knownhosts = "~/.ssh/known_hosts"
    removedhosts = "~/.ssh/removed_hosts"

    # open and remove h from knownhost
    f = open(knownhosts, 'r')
    lines = f.readlines()
    f.close()
    f = open(knownhosts, 'w')
    for line in lines:
        if line != h + "\n":
            f.write(line)
    f.close()

    # check if removed was successful
    if h in open(knownhosts).read():
        print "ERROR: Failed to removed "+ h + " from " + knownhosts
        sys.exit()
    else:
        print "SUCCESS: Removed " + h + " from " + knownhosts

    # write h to a backup file removedhosts
    with open(removedhosts, 'a+') as myfile:
        myfile.write(h + "\n")

    # check if addition was successful
    if h in open(removedhosts).read():
        print "SUCCESS: Added " + h + " to " + removedhosts
    else:
        print "ERROR: Failed to add " + h + " to  " + removedhosts

if __name__ == "__main__":
    main()
