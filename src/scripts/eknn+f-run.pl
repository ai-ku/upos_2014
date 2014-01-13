#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: eknn+f-run.pl seed nknn
Prints out inputs, output, number of seconds
};

my $ntest = shift or die "ntest $usage";
my $lang = shift or die "lang $usage";
my $K = shift or die "K $usage"; 
my $feat = shift or die "featfile $usage";
my $seed = shift or die "seed $usage";
my $nknn = shift or die "nknn $usage";
my $ndim = shift or die "ndim $usage";
my $Z = shift or die "Z $usage";
my $phi = shift or die "phi $usage";
my $nu = shift or die "nu $usage";

my $sc_restart = 1;
my $km_restart = 128;
my $test = "$lang.words.gz";
my $gold = "$lang.pos.gz";
my $subs = "$lang.sub.gz";
my $knnFile = "$lang.knn.gz";
my $tmp = tempdir("eknn+f-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";
my $pair_out = "$tmp/pairs.out";
my $pair_err = "$tmp/pairs.err";
my $knnPairs = "zcat $knnFile | knn-pairs.py $test $nknn ";
my $cmd0 = "$knnPairs > $pair_out  2> $pair_err";
my $input = "cat $pair_out | add-features-3.pl -f $feat";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed -p $phi -u $nu ";
my $kmeans = "sed -n s/^0://gp | wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";
my $cmd1 = "$input | $scode 2> $sc_err | $kmeans 2> $km_err | $kmeans2eval | $score 2> $ev_err";
my $tm = time;
system($cmd0);
system($cmd1);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $nknn, $ndim, $Z, @sc, @km, @ev, $phi, $nu, $tm)."\n";
