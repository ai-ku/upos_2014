#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: frame.pl seed numcluster language frame_name
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;
my $K = shift or die $usage;
my $lang = shift or die $usage;
my $frame = shift or die $usage;
my $type = shift or die $usage;

my $ndim = 25;
my $Z = 0.166;
my $sc_restart = 1;
my $km_restart = 128;

my $test = "$lang.words.gz";
my $gold = "$lang.pos.gz";
my $framein = "$lang.$frame.gz";
my $tmp = tempdir("f-$frame$type-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode.err";
my $sc_out = "$tmp/scode.out";
my $km_out = "$frame"."$type$seed.out";
my $km_err = "$tmp/kmeans.err";
my $ev_err = "$tmp/eval";
my $input = "zcat $framein";
my $wkmeansflag = " -w -l ";
my $kmeans2eval = " | wkmeans2eval.pl -t $test ";
my $scode2kmeans = "perl -ne 'print if s/^0://' | ";
if ($type eq "token"){
    $kmeans2eval = "";
    $wkmeansflag = "";
    $scode2kmeans = "";
}elsif ($type eq "ytoken"){
    $kmeans2eval = " | y2eval.py -s $seed -p $lang.$frame.gz -n 1";
    $scode2kmeans = "perl -ne 'print if s/^1://' | ";
}

my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed 2> $sc_err | gzip > $sc_out";
my $kmeans = "wkmeans $wkmeansflag -k $K -r $km_restart -s $seed  2> $km_err $kmeans2eval > $km_out";
my $score = "eval.pl -m -v -g $gold";
my $cmd0 = "$input | $scode";
my $cmd1 = "zcat $sc_out | $scode2kmeans $kmeans";
my $cmd2 = "cat $km_out |  $score 2> $ev_err";
my $tm = time;
system($cmd0);
system($cmd1);
system($cmd2);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $type, @sc, @km, @ev, $tm)."\n";
