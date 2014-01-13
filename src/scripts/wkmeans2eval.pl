#!/usr/bin/perl -w
use strict;

my $usage = qq{wkmeans2eval.pl -t test.tok < kmeans.out > eval.in
Construct input for eval from output of weighted kmeans
-t test file
};

use Getopt::Std;
our($opt_t);
getopt('t');
die $usage unless $opt_t;
$opt_t = "zcat $opt_t |" if $opt_t =~ /\.gz$/;

my %clus;
while (<>) {
    my ($w, $c) = split;
    die "Duplicate word: $w" if defined $clus{$w};
    $clus{$w} = $c;
}

open(FP, $opt_t) or die $!;
while(<FP>) {
    for my $w (split) {
	die "Unknown word: $w" if not defined $clus{$w};
	print $clus{$w}."\n";
    }
}
close(FP);
