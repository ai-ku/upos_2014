#!/usr/bin/perl -w
use strict;

my $usage = q{Usage: eknn+f-args.pl nclu lang ntok > args
};

my $seed = 10;
my $ndim = 25;
my $nknn = 12;
my $Z = 0.166;
my $phi = 50;
my $nu = 0.2;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $featfile =  shift or die $usage;
my $test = "$lang.pos.gz";
my $line = `zcat $test | wc -l`;

chomp($line);
for my $eknn qw(1 2 3 4 6 8 10 12 16 25 32 45 64) {
    $seed = 10;
    for (my $j=0; $j < 10; $j++) {
        print "$line\t$lang\t$K\t$featfile\t$seed\t$eknn\t$ndim\t$Z\t$phi\t$nu\n";
        $seed+=5;
    }
}
