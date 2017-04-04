#!/usr/bin/perl

# uptime.pl - an experiment in re-writing uptime for different os's

use Data::Dumper qw(Dumper);
#use Config;
#print "$Config{'osname'}\n";
# perl oses: http://alma.ch/perl/perloses.htm

if ( $^O =~ "linux" ) {
    # example uptime from debian linux command line (`uptime`)
    #  15:35:50 up 20:01,  1 user,  load average: 0.04, 0.02, 0.09

    open(P, '/proc/uptime');
    my $uptime = <P>;
    close(P);
    $uptime = (split(m/\s+/, $uptime))[0];

} elsif ( $^O =~ "darwin") {
    # example uptime from macOS Sierra (`sysctl -n kern.boottime`)
    # { sec = 1491070408, usec = 756788 } Sat Apr  1 12:13:28 2017 
    # or using the actual (`uptime`) utility 
    #  15:54  up 23:16, 3 users, load averages: 1.24 1.41 1.47

    # get current time
    my @datetime = (split / /, `date`);
    chomp(@datetime);
    my $currtime = $datetime[4];

    # get up (time)
    my @uptime = (split / /, `sysctl -n kern.boottime`, 9);
    chomp(@uptime);
    my $hours = $uptime[6];
    my $boottime = $uptime[3];

    # TODO: get users
    # TODO: get load average

    # print it out together
    print "$currtime\n";
    printf "Last boot date: %s\n", $boottime;

#    printf "Last boot date: %s (%.2f hours up)\n", $boottime, $hours; 
#    print Dumper \@datetime;
    print Dumper \@uptime;

} else {
    print "ERROR: Unknown OS!\n";
}
