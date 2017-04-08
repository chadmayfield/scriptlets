#!/usr/bin/perl -w

# gethostnamebyaddr.pl - show hostname/alias based on ip address  

use strict;
use Socket;
use Data::Dumper;

if ( @ARGV != 1 ) {
    print "ERROR: You must supply an ip address!\n";
    exit;
}

my $ip = $ARGV[0];
my @i = gethostbyaddr(inet_aton($ip), AF_INET);

# define var based on array and shift off stack
my $hn = $i[0];
shift(@i);
my $alias = $i[0];
shift(@i);
my $addrtype = $i[0];
shift(@i);
my $len = $i[0];
shift(@i);

# print it all out
printf("%-15s %s\n", "Hostname:", $hn);
printf("%-15s %s\n", "Alias:", $alias);
#printf("%-15s %s\n", "Type:", $addrtype);
#printf("%-15s %s\n", "Length:", $len);

#foreach (@i) {
#    print "          = ", inet_ntoa($_), "\n";
#}

#EOF
