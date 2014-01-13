#!/usr/bin/perl

if($ARGV[0] =~ /^-(\d+)$/) {
    $n = $1; shift; 
} else {
    $n = 10;
}

while(<>) {
    if($. <= $n) {
	$s[$.-1] = $_;
    } else {
	$r = int(rand $.);
	if($r < $n) {
	    $s[$r] = $_;
	}
    }
}

for (@s) { print; }
