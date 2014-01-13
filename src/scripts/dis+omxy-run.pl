#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: dis+xy-run.pl seed nsub langcluster lang featfile
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;
my $nsub = shift or die $usage;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $featfile = shift or die $usage;

my $ndim = 25;
my $Z = 0.166;
my $ntest = 1173766;
my $sc_restart = 1;
my $km_restart = 128;
my $test = "$lang.words.gz";
my $gold = "$lang.pos.gz";
my $subf = "$lang.sub.gz";
my $tmp = tempdir("dis+omxyrun-XXXX", CLEANUP => 1);
my $pairs = "$tmp/pairs.gz";
my $sc_out = "$tmp/scode.gz";
my $sc_err = "$tmp/scode";
my $km_out = "xyftoken$seed.out";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $input = "perl -le \'print \"$subf\" for 1..$nsub\' | xargs zcat | grep -v \'^</s>\'";
my $features = "add-features-3.pl -f $featfile";
my $wordsub = "wordsub -s $seed";
my $cmd0 = "$input | $wordsub | $features | gzip > $pairs";

my $scode = "zcat $pairs | scode -r $sc_restart -d $ndim -z $Z -s $seed 2> $sc_err | sed -n /^[01]:/p | gzip > $sc_out";
my $scode2kmeans = "x+y2kmeans.py -p $pairs";
my $kmeans = "wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "x+y2eval.py -s $seed -n $nsub -p $pairs > $km_out";
my $score = "eval.pl -m -v -g $gold";
my $cmd1 = "$scode";
my $cmd2 = "zcat $sc_out | $scode2kmeans | $kmeans 2> $km_err | $kmeans2eval";
my $cmd3= "cat $km_out | $score 2> $ev_err";

my $tm = time;

system($cmd0);
system($cmd1);
system($cmd2);
system($cmd3);

$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $nsub, @sc, @km, @ev, $tm)."\n";
