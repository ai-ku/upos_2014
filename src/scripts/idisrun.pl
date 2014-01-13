#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: wsrun.pl seed nsub ndim Z
Prints out inputs, output, number of seconds
};
my $runid = shift or die $usage;
my $ntest = shift or die $usage;
my $lang = shift or die $usage;
my $K = shift or die $usage; 
my $seed = shift or die $usage;
my $nsub = shift or die $usage;
my $ndim = shift or die $usage;
my $Z = shift or die $usage;
my $phi = shift or die $usage;
my $nu = shift or die $usage;

my $sc_restart = 1;
my $km_type_restart = 128;
my $km_ins_restart = 128;
my $test = "$lang.words.gz";
my $gold = "$lang.pos.gz";
my $subs = "$lang.sub.gz";
my $tmp = tempdir("ws-instance-run-XXXX", CLEANUP => 1);
my $wordsub_out = "$tmp/ws.out.gz";
my $sc_out = "$tmp/scode.gz";
my $sc_err = "$tmp/scode.err";
my $km_ins_out = "$tmp/ins$seed.out";
my $km_type_out = "$tmp/type$seed.out";
my $km_ins_err = "$tmp/ins.kmeans";
my $km_type_err = "$tmp/type.kmeans";
my $ins_ev_err = "$tmp/ins.eval";
my $type_ev_err = "$tmp/type.eval";
my $input = "zcat $lang";
my $wordsub = "perl -le 'print \"$subs\" for 1..$nsub' | xargs zcat | grep -v '^</s>' | wordsub -s $seed | gzip > $wordsub_out";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed -p $phi -u $nu "; 
my $barxy = "average-and-norm.py -w $wordsub_out -n $ntest --xy true";
my $kmeans_type = "wkmeans -k $K -r $km_type_restart -l -w -s $seed";
my $kmeans_ins = "wkmeans -k $K -r $km_ins_restart -l -w -s $seed";
my $kmeans2eval = "cut -f2"; 
my $score = "eval.pl -m -v -g $gold";
my $cmd0 = "zcat $wordsub_out | $scode 2> $sc_err | gzip > $sc_out";
my $instance = "zcat $sc_out | $barxy | $kmeans_ins 2> $km_ins_err | $kmeans2eval > $km_ins_out";
my $scode2kmeans = "perl -ne 'print if s/^0://'";
my $type_kmeans2eval = "wkmeans2eval.pl -t $test";
# Instance calculation is longer, send type to background
my $type = "zcat $sc_out | $scode2kmeans | $kmeans_type 2> $km_type_err | $type_kmeans2eval > $km_type_out &";
my $type_eval = "cat $km_type_out | $score 2> $type_ev_err";
my $ins_eval= "cat $km_ins_out | $score 2> $ins_ev_err";
my $tm = time;
system($wordsub);
system($cmd0);
system($type);
system($instance);
system($type_eval);
system($ins_eval);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @tkm = split(' ', `cat $km_type_err`);
my @tev = split(' ', `cat $type_ev_err`);
my @ikm = split(' ', `cat $km_ins_err`);
my @iev = split(' ', `cat $ins_ev_err`);

print join("\t", $runid, $seed, $nsub, $ndim, $Z, @sc, @tkm, @tev, @ikm, @iev, $phi, $nu, $tm)."\n";
