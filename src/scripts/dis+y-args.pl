#!/usr/bin/perl -w
use strict;

my $seed = 1;
my $ncl = shift or die("missing number of clusters\n");
my $lang = shift or die("missing language\n");
my $i = shift or die("missing substitute number\n");

for (my $j=0; $j < 10; $j++) {
    print "$seed $i $ncl $lang\n";
    $seed+=5;
}
