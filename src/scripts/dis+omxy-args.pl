#!/usr/bin/perl -w
use strict;

my $seed = 1;
my $ncl = shift or die("missing number of clusters\n");
my $lang = shift or die("missing language\n");
my $i = shift or die("missing substitute number\n");
my $featfile = shift or die("feature file\n");

for (my $j=0; $j < 10; $j++) {
    print "$seed $i $ncl $lang $featfile\n";
    $seed+=5;
}
