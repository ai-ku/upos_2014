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
my $tmp = tempdir("ws+f-$seed-$ndim-$nsub-$Z-XXXX", CLEANUP => 0);
my $wordsub_out = "$tmp/ws.out.gz";
my $sc_out = "$tmp/scode.gz";
my $sc_err = "$tmp/scode";
my $km_ins_out = "$tmp/ins$seed.out";
my $km_type_out = "$tmp/type$seed.out";
my $km_ins_err = "$tmp/ins.kmeans";
my $km_type_err = "$tmp/type.kmeans";
my $ev_ins_out= "$tmp/ins.cl";
my $ev_type_out = "$tmp/type.cl";
my $ev_ins_err = "$tmp/ins.eval";
my $ev_type_err = "$tmp/type.eval";

my $wordsub = "perl -le 'print \"$subs\" for 1..$nsub' | xargs zcat | grep -v '^</s>'| wordsub -s $seed | gzip > $wordsub_out";
my $input = "zcat $wordsub_out | add-features-3.pl -f $feat";
my $scode = "scode -r $sc_restart -d $ndim -z $Z -s $seed -p $phi -u $nu ";
my $barxy = "average-and-norm.py -w $wordsub_out -n $ntest --xy true";
my $kmeans_type = "sed -n s/^0://gp | wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans_ins = "$barxy | wkmeans -k $K -r $km_restart -l -w -s $seed";
my $type_kmeans2eval = "wkmeans2eval.pl -t $test";
my $ins_kmeans2eval = "cut -f2"; 
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$input | $scode 2> $sc_err | gzip > $sc_out"; 
# send to back ground eval_ins takes much longer time
my $cluster_type= "zcat $sc_out| $kmeans_type 2> $km_type_err | $type_kmeans2eval > $ev_type_out&";
my $cluster_ins= "zcat $sc_out| $kmeans_ins 2> $km_ins_err | $ins_kmeans2eval > $ev_ins_out";
my $eval_ins = "cat $ev_ins_out |$score 2> $ev_ins_err";
my $eval_type = "cat $ev_type_out | $score 2> $ev_type_err";

my $tm = time;
system($wordsub);
system($cmd);
system($cluster_type);
system($cluster_ins);
system($eval_type);
system($eval_ins);
system("rm $wordsub_out $sc_out");
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @tkm = split(' ', `cat $km_type_err`);
my @tev = split(' ', `cat $ev_type_err`);
my @ikm = split(' ', `cat $km_ins_err`);
my @iev = split(' ', `cat $ev_ins_err`);

print join("\t", $seed, $nsub, $ndim, $Z, @sc, @tkm, @tev, @ikm, @iev, $phi, $nu, $tm)."\n";
