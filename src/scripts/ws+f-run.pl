#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: ws+f-run.pl seed nsub feature-table
Prints out inputs, output, number of seconds
};

my $seed = $ARGV[0];
my $nsub = $ARGV[1];

my $ndim = 25;
my $Z = 0.166;
my $sc_restart = 1;
my $km_restart = 128;
my $K = 45;
my $test = 'wsj.words.gz';
my $gold = 'wsj.pos.gz';

my $tmp = tempdir("ws+f-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $input = "perl -le 'print \"wsj.sub.gz\" for 1..$nsub' | xargs zcat | wordsub -s $seed | add-features.pl -f wsj.features.gz";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed";
my $kmeans = "sed -n s/^0://gp | wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$input | $scode 2> $sc_err | $kmeans 2> $km_err | $kmeans2eval | $score 2> $ev_err";

my $tm = time;
system($cmd);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $nsub, @sc, @km, @ev, $tm)."\n";
