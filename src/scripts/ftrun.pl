#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: ftrun.pl seed
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;

my $nsub = 45;
my $ndim = 25;
my $Z = 0.166;
my $ntest = 1173766;
my $sc_restart = 1;
my $km_restart = 128;
my $K = 45;
my $test = 'wsj.words.gz';
my $gold = 'wsj.pos.gz';

my $tmp = tempdir("ftrun-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $wordsub = "wordsub '<zcat wsj.sub.gz' $nsub $seed";
my $feat = 'add-features.pl -f featuretable';
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed";
my $scode2kmeans = "perl -ne 'print if s/^0://'";
my $kmeans = "wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$wordsub | $feat | $scode 2> $sc_err | $scode2kmeans | $kmeans 2> $km_err | $kmeans2eval | $score 2> $ev_err";

my $tm = time;
system($cmd);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $nsub, @sc, @km, @ev, $tm)."\n";
