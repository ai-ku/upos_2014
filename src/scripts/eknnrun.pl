#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: eknnrun.pl seed nknn ndim Z
Prints out inputs, output, number of seconds
};
my $runid = shift or die $usage;
my $ntest = shift or die $usage;
my $lang = shift or die $usage;
my $K = shift or die $usage; 
my $seed = shift or die $usage;
my $nknn = shift or die $usage;
my $ndim = shift or die $usage;
my $Z = shift or die $usage;
my $phi = shift or die $usage;
my $nu = shift or die $usage;

my $sc_restart = 1;
my $km_restart = 128;
my $test = "$lang.words.gz";
my $knnFile = "$lang.knn.gz";
my $gold = "$lang.pos.gz";
my $subs = "$lang.sub.gz";
my $tmp = tempdir("eknnrun-XXXX", CLEANUP => 1);
my $readyPairFile = "";
my $pair_out = "$tmp/pairs.gz";
my $pair_err = "$tmp/pairs.err";

if (-e  "$lang.k$nknn.gz") {
	print STDERR "Precomputed pairfile exists, run:$runid is using $lang.k$nknn.gz\n";
	$readyPairFile = "$lang.k$nknn.gz";
	$pair_out = "$lang.k$nknn.gz";
} 
my $km_out = "$tmp/type$seed.out";
my $km_err = "$tmp/kmeans";
my $sc_err = "$tmp/scode";
my $ev_err = "$tmp/eval";
my $input = "zcat $lang";
my $knnPairs = "zcat $knnFile | knn-pairs.py $test  $nknn ";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed -p $phi -u $nu";
my $scode2kmeans = "perl -ne 'print if s/^0://'";
my $kmeans = "wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";
my $cmd0 = "$knnPairs 2> $pair_err | gzip > $pair_out";
my $cmd1 = "zcat $pair_out | $scode 2> $sc_err | $scode2kmeans | $kmeans 2> $km_err | $kmeans2eval > $km_out";
my $cmd2 = "cat $km_out | $score 2> $ev_err";
my $tm = time; 
system($cmd0) unless($readyPairFile);
system($cmd1);
system($cmd2);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $runid, $seed, $nknn, $ndim, $Z, @sc, @km, @ev, $phi, $nu, $tm)."\n";
