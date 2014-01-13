#!/usr/bin/perl -w
# prints the unknown percentage of a given vocabulary and file
# prints the total ration of words concatinated with _, probably the proper nouns like Alan_Turing
# prints the unknown percentage after splitting the words with "_" 
# prints the tag distributions
# prints the unknown word percentages
#
use strict;

my $usage = qq{Usage:./unknown.pl voc input
Prints out unknown percentage of input
};

die $usage if @ARGV < 2;
open(V,"gzip -dc $ARGV[0] |");
open(F,"gzip -dc $ARGV[1] |");
my (%voc, %unklist);
while(<V>){
  chomp;
  my @l = split;
  $voc{$l[0]}++;
}
my ($u, $all, $under, $splitu, $splita) = (0, 0, 0, 0, 0);
my %tagDist;
while(<F>){
  chomp;
  next unless($_);
  my ($w, $p) = split;
  if ( not defined $voc{$w}) {
    $unklist{$w}++;
    $u++; 
    if ($w =~ /_/) { 
      $tagDist{$p}++;
      $under++ 
    }
  }
  $all++;
  my @sp = split("_", $w);
  foreach(@sp) {
    $splitu++ unless(defined $voc{$_});
    $splita++;
  }
}
close(V);
close(F);
print "## unknown/all\t".$u/$all . "\n";
print "## under/unknown\t". $under / $u . "\tunder/all\t" . $under/$all. "\n";
print "## splitUnk/all:\t" . $splitu / $splita . "\n";
print "## Tag distribution\n";
foreach my $p (keys(%tagDist)) {
  print "$p\t$tagDist{$p}\n";
}
print "##Unknown word distribution\n";
my @keys = sort { $unklist{$b} <=>$unklist{$a} } keys %unklist;
foreach my $k (@keys) {
  print "$k\t$unklist{$k}\t" . $unklist{$k} / $all. "\n";
}
