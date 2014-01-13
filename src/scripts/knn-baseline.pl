#!/usr/bin/perl -w
# Unweighted supervised loocv knn baseline
use strict;
my $usage = qq{zcat wsj.knn.gz | knn-baseline.pl -g wsj.pos.gz};

use Getopt::Std;
our($opt_g, $opt_k) = ('wsj.pos.gz', 10);
getopt('gk');

$opt_g = "zcat $opt_g |" if $opt_g =~ /\.gz$/;
open(GOLD, $opt_g) or die $!;
my @gold = <GOLD>;
close(GOLD);

my ($score0, $score1, $score2, $total);
while(<>) {
    my @a = split;
    die unless $a[0] == $.-1;
    my $g = $gold[$a[0]];
    my %cnt;
    $cnt{$g} = 0;
    for (my $k = 1; $k <= $opt_k; $k++) {
	my $gk = $gold[$a[2*$k - 1]];
	$cnt{$gk}++;
    }
    my ($max, $rep);
    for my $gk (keys %cnt) {
	if (not defined $max or $cnt{$gk} > $max) {
	    $max = $cnt{$gk};
	    $rep = 1;
	} elsif ($cnt{$gk} == $max) {
	    $rep++;
	}
    }
    if ($cnt{$g} == $max) {
	$score2++;
	$score1 += 1/$rep;
	$score0++ if $rep == 1;
    }
    $total++;
}

printf("%f\t%d\t%f\t%d\t%d\n", $score1 / $total, $score0, $score1, $score2, $total);
