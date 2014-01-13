#!/usr/bin/perl -w
use strict;

sub myopen {
    my ($path) = @_;
    $path = "zcat $path |" if $path =~ /\.gz$/;
    open(my $fh, $path);
    return $fh;
}

my @fp;
push @fp, myopen($_) for @ARGV;

while(1) {
    my $eof = 0;
    my $col = 0;
    for my $fh (@fp) {
	my $line = <$fh>;
	if (not defined $line) {
	    $eof = 1;
	    last;
	}
	chomp($line);
	print "\t" if $col++;
	print $line;
    }
    last if $eof;
    print "\n";
}

close for @fp;
