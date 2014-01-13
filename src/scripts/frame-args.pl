#!/usr/bin/perl -w
use strict;

my $langcl = shift or die("missing number of clusters");
my $lang = shift or die("missing number of clusters");
my $frame = shift or die("missing frame");
my $type =  shift or die("missing frame");

for my $seed (1 .. 10) {
    print "$seed $langcl $lang $frame $type\n";
    $seed += 5;
}
