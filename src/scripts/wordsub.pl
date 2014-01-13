#!/usr/bin/perl -w
use strict;

my $usage = qq{wordsub.pl -n N [-s S] < sub-input
Reads a substitute file and prints word and a random substitute on each line.
-n <number of substitutes per word>
-s <random seed>
};

use Getopt::Std;
our($opt_n, $opt_s, $opt_h);
getopts('n:s:h');
die $usage if $opt_h;
$opt_n = 1 unless $opt_n;
srand($opt_s) if $opt_s;

while(<>) {
    my @a = split;
    my $w = $a[0];
    next if $w eq '</s>';
    my $sum = 0;
    my @sub;
    for (my $i = 1; $i < $#a; $i += 2) {
	my $p = 10 ** $a[$i+1];
	$sum += $p;
	for (my $n = 0; $n < $opt_n; $n++) {
	    if (rand($sum) < $p) {
		$sub[$n] = $a[$i];
	    }
	}
    }
    for (my $n = 0; $n < $opt_n; $n++) {
	print "$w\t$sub[$n]\n";
    }
}
