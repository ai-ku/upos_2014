#!/usr/bin/perl -w
use strict;

my $usage = q{Usage: wsrun-args.pl nclu lang ntok > args
};

my $seed = 10;
my $ndim = 25;
my $nsub = 32;
my $Z = 0.166;
my $phi = 50;
my $nu = 0.2;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $featfile =  shift or die $usage;
my $test = "$lang.pos.gz";
my $line = `zcat $test | wc -l`;

chomp($line);
for my $nsub qw(1 2 3 4 6 8 10 12 16 25 32 45 64 90 128) {
    $seed = 10;
    for (my $j=0; $j < 10; $j++) {
        print "$line\t$lang\t$K\t$featfile\t$seed\t$nsub\t$ndim\t$Z\t$phi\t$nu\n";
        $seed+=5;
    }
}

# for my $Z (
#  	   0.044194, 0.062500, 0.088388, 0.125000, 0.176777,
#  	   0.250000, 0.353553, 0.500000, 0.707107, 1.000000, 1.414214,
#  	   2.000000, 2.828427) { 
#      for my $s (0 .. 9) {
#        print "$line\t$lang\t$K\t$featfile\t$seed\t$nsub\t$ndim\t$Z\t$phi\t$nu\n";
#        $seed+=5;
#      }
#    }

# for my $ndim (2, 4, 8){
# #10, 25, 50, 75, 100, 150, 200) {
# 	$seed = 10;
# 	for my $s (0 .. 9) {
#     print "$line\t$lang\t$K\t$featfile\t$seed\t$nsub\t$ndim\t$Z\t$phi\t$nu\n";
#     $seed+=5;
# 	}
# }
# 
# 
