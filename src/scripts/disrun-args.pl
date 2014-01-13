#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $usage = q{Usage: wsrun-args.pl nclu lang
};

my $seed = 1;
my $ndim = 25;
my $nsub = 12;
my $Z = 0.166;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $nu = 0.2;
my $phi = 50;
my $test = "$lang.pos.gz";
my $line = `zcat $test | wc -l`;
my $runid = 1;
chomp($line);

for my $nsub qw(1 2 3 4 6 8 10 12 16 25 32 45 64 90 128) {
    $seed=10;
    for my $s (0 .. 9) {
        print "$runid\t$line\t$lang\t$K\t$seed\t$nsub\t$ndim\t$Z\t$phi\t$nu\n";
        $seed += 5;
    }
    $runid++;
}
#for my $Z (0.011049, 0.015625, 0.022097,
# 	   0.031250, 0.044194, 0.062500, 0.088388, 0.125000, 0.176777,  # my %Zh = ('10' => 0.168, 
# 	   0.250000, 0.353553, 0.500000, 0.707107, 1.000000, 1.414214,  # 	  '25' => 0.145, 
# 	   2.000000, 2.828427, 4.000000, 5.656854, 8.000000, 11.31370) {# 	  '50' => 0.140, 
#     for my $s (0 .. 9) {                                          # 	  '75' => 0.139, 
# 	$seed++;                                                        # 	  '100' => 0.136, 
# 	print "$line\t$lang\t$K\t$seed\t$nsub\t$ndim\t$Z\n";            # 	  '150' => 0.136,
#     }                                                             # 	  '200' => 0.136);
# }
# for my $ndim (10, 25, 50, 75, 100, 150, 200) {
#     for my $nsub qw(1 2 3 4 6 8 10 12 16 25 32 45 64 90 128 180 256) {
# 	$Z = $Zh{$ndim};	
# 	$seed = 1;
# 	for my $s (0 .. 9) {
# 	    print "$runid\t$line\t$lang\t$K\t$seed\t$nsub\t$ndim\t$Z\t$phi\t$nu\n";
# 	    $seed++;
# 	}
# 	$runid++;
#     }
# }

#for my $Z (0.011049, 0.015625, 0.022097,
# 	   0.031250, 0.044194, 0.062500, 0.088388, 0.125000, 0.176777,
# 	   0.250000, 0.353553, 0.500000, 0.707107, 1.000000, 1.414214,
# 	   2.000000, 2.828427, 4.000000, 5.656854, 8.000000, 11.31370) {
#     for my $s (0 .. 9) {
# 	$seed++;
# 	print "$line\t$lang\t$K\t$seed\t$nsub\t$ndim\t$Z\n";
#     }
# }

# for my $ndim (2, 3, 4, 6, 8, 11, 16, 25, 32, 45, 64, 90, 128, 180, 256, 512) {
#     for my $nsub qw(1 2 3 4 6 8 10 12 16 25 32 45 64 90 128) {
# 	for my $Z (0.166, 0.011049, 0.015625, 0.022097,
# 		   0.031250, 0.044194, 0.062500, 0.088388, 0.125000, 0.176777,
# 		   0.250000, 0.353553, 0.500000, 0.707107, 1.000000, 1.414214,
# 		   2.000000, 2.828427, 4.000000, 5.656854, 8.000000, 11.31370) {
# 	    for (my $nu=0.1; $nu <= 1; $nu += 0.1) {
# 		for (my $phi=10; $phi <= 100; $phi += 10) {
# 		    $seed = 1;
# 		    for my $s (0 .. 9) {
# 			print "$runid\t$line\t$lang\t$K\t$seed\t$nsub\t$ndim\t$Z\t$phi\t$nu\n";
# 			$seed++;
# 		    }
# 		    $runid++;
# 		}
# 	    }
# 	}
#     }
# }
