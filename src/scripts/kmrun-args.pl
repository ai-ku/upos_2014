#!/usr/bin/perl -w
use strict;
# 14 secs per iteration without weights
# .8 secs per iteration with weights

my $seed = 0;

for my $file ('rpart.scode.gz', 'wordsub.scode.gz') {
    for my $nstart (1, 2, 3, 4, 6, 8, 10, 16, 25, 32, 45, 64, 90, 128, 256, 512, 1024) {
	for my $s (0 .. 9) {
	    $seed++; print "$seed $file 1 $nstart\n";
	    $seed++; print "$seed $file 0 $nstart\n" if $nstart <= 128;
	}
    }
}

