#!/usr/bin/perl -w
use strict;

my $langcl = shift or die("missing number of clusters");
my $lang = shift or die("missing number of clusters");

for my $seed (1 .. 10) {
    print "$seed $langcl $lang\n";    
    $seed+= 5
}
