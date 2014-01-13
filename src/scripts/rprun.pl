#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: rprun.pl seed npart ndim Z
Runs random partition experiment with given settings.
Prints out inputs, output, number of seconds.
};

my $seed = shift or die $usage;
my $npart = shift or die $usage;
my $ndim = shift or die $usage;
my $Z = shift or die $usage;

my $tmp = tempdir("rprun-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $ntest = 1173766;
my $sc_restart = 1;
my $km_restart = 128;
my $K = 45;
my $test = 'wsj.words.gz';
my $gold = 'wsj.pos.gz';

my $input = 'zcat wsj.knn.gz';
my $rpart = "rpart.pl -n $ntest -p $npart -s $seed";
my $rpart2scode = "join.pl wsj.words.gz -";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed";
my $scode2kmeans = "perl -ne 'print if s/^0://'";
my $kmeans = "wkmeans -k $K -r $km_restart -s $seed -w -l";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";

my $cmd = "$input | $rpart | $rpart2scode | $scode 2> $sc_err | $scode2kmeans | $kmeans 2> $km_err | $kmeans2eval | $score 2> $ev_err";

my $tm = time;
system($cmd);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $npart, $ndim, $Z, @sc, @km, @ev, $tm)."\n";
