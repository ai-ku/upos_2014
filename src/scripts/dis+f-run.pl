#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: ws+f-run.pl seed nsub
Prints out inputs, output, number of seconds
};

my $ntest = shift or die "ntest $usage";
my $lang = shift or die "lang $usage";
my $K = shift or die "K $usage"; 
my $feat = shift or die "featfile $usage";
my $seed = shift or die "seed $usage";
my $nsub = shift or die "nsub $usage";
my $ndim = shift or die "ndim $usage";
my $Z = shift or die "Z $usage";
my $phi = shift or die "phi $usage";
my $nu = shift or die "nu $usage";

my $sc_restart = 1;
my $km_restart = 128;
my $test = "$lang.words.gz";
my $gold = "$lang.pos.gz";
my $subs = "$lang.sub.gz";
my $tmp = tempdir("ws+f-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $input = "perl -le 'print \"$subs\" for 1..$nsub' | xargs zcat | wordsub -s $seed | add-features-3.pl -f $feat";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed -p $phi -u $nu ";
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

print join("\t", $seed, $nsub, $ndim, $Z, @sc, @km, @ev, $phi, $nu, $tm)."\n";
