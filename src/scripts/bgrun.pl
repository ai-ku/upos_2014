#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: bgrun.pl seed langcl language
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $ndim = 25;
my $Z = 0.166;
my $ntest = 1173766;
my $sc_restart = 1;
my $km_restart = 128;
my $test = "$lang.words.gz";
my $gold = "$lang.pos.gz";

my $tmp = tempdir("bgrun-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $input = "zcat bigram.$lang.pairs.gz";
my $scode = "scode -m -r $sc_restart -d $ndim -z $Z -s $seed";
my $kmeans = "wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$input | $scode 2> $sc_err | $kmeans 2> $km_err | $kmeans2eval | $score 2> $ev_err";

my $tm = time;
system($cmd);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $ndim,$Z, @sc, @km, @ev, $tm)."\n";
