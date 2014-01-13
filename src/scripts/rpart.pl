#!/usr/bin/perl -w
use strict;

my $usage = qq{rpart.pl -n N -p P [-s S] < knn-input
Creates random partitions based on the knn data
-n <number of instances>
-p <number of partitions>
-s <random seed>
};

use Getopt::Std;
our($opt_n, $opt_p, $opt_s);
getopt('nps');
die $usage unless $opt_n;
die $usage unless $opt_p;
srand($opt_s) if $opt_s;

my %centroids;
while (scalar(keys(%centroids)) < $opt_p) {
    $centroids{int(rand($opt_n))} = 1;
}

while(<>) {
    my $c = -1;
    /^\S+\s+/g; # first number is the word id
    while(/(\S+)\s+\S+\s+/g) {
	if (defined $centroids{$1}) {
	    $c = $1;
	    last;
	}
    }
    print "$c\n";
}
