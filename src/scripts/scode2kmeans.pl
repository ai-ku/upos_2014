#!/usr/bin/perl -w
use strict;

my $usage = qq{scode2kmeans.pl -t <test> < scode.out > kmeans.in
Convert scode output to kmeans input
-t test file
};

use Getopt::Std;
our($opt_t);
getopt('t');
die $usage unless $opt_t;
$opt_t = "zcat $opt_t |" if $opt_t =~ /\.gz$/;

# Read scode input
my %scode;
while(<>) {
    next unless s/^0://;
    my ($word, $weight, $coor) = /^(\S+)\s+(\S+)\s+(.+)/;
    $scode{$word} = $coor;
}

open(FP, $opt_t) or die $!;
while(<FP>) {
    for my $w (split) {
	die "Word [$w] not found.\n" unless defined $scode{$w};
	print "$scode{$w}\n";
    }
}
close(FP);
