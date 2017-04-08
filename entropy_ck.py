#!/usr/bin/python

# entropy_ck.py - calculates the Shannon entropy of a string

# author  : Chad Mayfield (code@chadmayfield.com)
# license : gplv3

import os, sys, math

sname = os.path.basename(sys.argv[0])
if len(sys.argv) == 1:
    print "Usage: " + sname  + " <password>"
    sys.exit()

# modified from http://stackoverflow.com/a/2979208
def entropy(string):
    # get probability of chars in string
    prob = [ float(string.count(c)) / len(string) for c in dict.fromkeys(list(string)) ]

    # calculate the entropy
    entropy = - sum([ p * math.log(p) / math.log(2.0) for p in prob ])

    return entropy

c_entropy = entropy(sys.argv[1])
p_length = len(sys.argv[1])
ttl_entropy = entropy(sys.argv[1]) * len(sys.argv[1])

print 'passwd length:  ', p_length
print 'entropy/char:   ', c_entropy
print 'actual entropy: ', ttl_entropy, 'bits'
