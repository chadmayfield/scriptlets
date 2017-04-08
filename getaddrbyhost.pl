#!/usr/bin/perl -w

# getaddrbyhost.pl - lookup a hosts ip by hostname 

use strict;
use Socket;
use Data::Dumper;

if ( @ARGV != 1 ) {
    print "ERROR: You must supply a hostname!\n";
    exit;
}

my @address = inet_ntoa(scalar(gethostbyname($ARGV[0])));

#print Dumper(\@address);

my $count = 1;
foreach my $n (@address) {
    printf("%-15s %s\n", "IPAddress".$count.":", $n);
    shift(@address);
    $count++;
}

#EOF
