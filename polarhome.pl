#!/usr/bin/perl

# polarhome.pl - simplify ssh connection to polarhome.com servers without 
#                having to remember usernames and ports (port info at bottom)

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

use warnings;
use strict;

if ( @ARGV != 1 ) {
    print "ERROR: You must supply a host to connect!\n";
    print "  e.g. $0 <host>\n";
    exit 1;
}

our $user;
my $host = shift @ARGV;
my $hostck = "-oStrictHostKeyChecking=no";
my $ident = "-i ~/.ssh/id_rsa_polarhome";

# our hash with host and port
my %hosts = (
    vax => "705",
    freebsd => "715",
    solaris => "725",
    openbsd => "735",
    netbsd => "745",
    debian => "755",
    alpha => "765",
    aix => "775",
    hpux => "785",
    redhat => "795",
    ultrix => "805",
    qnx => "815",
    irix => "825",
    tru64 => "835",
    openindiana => "845",
    suse => "855",
    openstep => "865",
    mandriva => "875",
    ubuntu => "885",
    scosysv => "895",
    unixware => "905",
    dragonfly => "915",
    centos => "925",
    miros => "935",
    hurd => "945",
    minix => "955",
    raspberrypi => "975",
#    plan9 => "",
);

# debug
#print "size of hash:  " . keys( %hosts ) . " hosts.\n--------\n";

# ik there's a better way to do this, but i'm too lazy to fight it right now
my $count =0;
# iterate through hash and check if @ARGV[0] exists
while (my ($key, $value) = each(%hosts)) {
    if ( $key eq "$host" ) {
        # dynamically set username based on host
        if ( $key =~ m/(hpux|minix|openindiana|qnx|solaris|tru64)/ ) {
            $user = "user1";
        } elsif ( $key =~ m/(aix|alpha|solaris|ultrix|vax)/) {
            $user = "user2";
        } else {
            print "ERROR: You don't have an account on $host!\n";
            exit 1;
        }
        # ssh keys must be setup or this will not work
        exec("ssh -tt $ident $hostck -l $user -p $value $key.polarhome.com");
    } else {
        $count++
    }

    # debug
    #print "$key => $value\n";
}

if ( $count >= keys(%hosts) ) {
    print "ERROR: Host ($host) not found! Please check it and try again.\n";
}

# -----------------------------------------------------------------------------
#     POLARHOME HOSTNAME | PORT | DIRECT PORTS       SERVICE PORTS
#    =========================================       =============
#        vax.polarhome.com  70x   2000-2999          ftp      xx1
#    freebsd.polarhome.com  71x  10000-14999         telnet   xx2
#    solaris.polarhome.com  72x  25000-29999         http     xx3
#    openbsd.polarhome.com  73x  15000-19999         https    xx4
#     netbsd.polarhome.com  74x  20000-24999         ssh      xx5
#     debian.polarhome.com  75x  30000-34999         pop3     xx6
#      alpha.polarhome.com  76x   3000-3999          imap     xx7
#        aix.polarhome.com  77x  35000-39999         usermin  xx8
#       hpux.polarhome.com  78x  40000-44999         imaps    xx9
#     redhat.polarhome.com  79x   5000-9999
#     ultrix.polarhome.com  80x   1025-1999
#        qnx.polarhome.com  81x   4000-4999
#       irix.polarhome.com  82x  45000-46999
#      tru64.polarhome.com  83x  47000-49999
#openindiana.polarhome.com  84x
#       suse.polarhome.com  85x  59000-59999
#   openstep.polarhome.com  86x  52000-52999
#   mandriva.polarhome.com  87x  54000-55999
#     ubuntu.polarhome.com  88x  56000-58999
#    scosysv.polarhome.com  89x  61000-61999
#   unixware.polarhome.com  90x  60000-60999
#  dragonfly.polarhome.com  91x  62000-62999
#     centos.polarhome.com  92x  63000-63999
#      miros.polarhome.com  93x  64000-64100
#       hurd.polarhome.com  94x
#      minix.polarhome.com  95x
#raspberrypi.polarhome.com  97x
#      plan9.polarhome.com        50000-51999
# -----------------------------------------------------------------------------

#EOF
