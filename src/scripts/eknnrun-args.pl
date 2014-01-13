#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $usage = q{Usage: eknnrun-args.pl nclu lang
};

my $seed = 1;
my $ndim = 25;
my $nknn = 16;
my $Z = 0.166;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $nu = 0.2;
my $phi = 50;
my $test = "$lang.pos.gz";
my $line = `zcat $test | wc -l`;
my $runid = 1;
chomp($line);

for my $nknn qw(1 2 3 4 6 8 10 12 16 25 32 45 64 90 128) {
#		for my $Z (0.011049, 0.015625, 0.022097,
# 	   		0.031250, 0.044194, 0.062500, 0.088388, 0.125000, 0.176777,
#   			0.250000, 0.353553, 0.500000, 0.707107, 1.000000, 1.414214,
# 	   		2.000000, 2.828427, 4.000000, 5.656854, 8.000000, 11.31370) {
   			$seed=10;
   	 		for my $s (0 .. 9) {
        			print "$runid\t$line\t$lang\t$K\t$seed\t$nknn\t$ndim\t$Z\t$phi\t$nu\n";
        			$seed += 5;
    			}
    			$runid++;
#		}
}
