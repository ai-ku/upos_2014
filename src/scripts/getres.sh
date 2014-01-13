#!/bin/bash
SCORE=$1
SUBS=$2
if [ -z "$1" ]
then
    SCORE="s"
fi

if [ -z "$2" ]
then
    SUBS="64"
fi

more */dis+xyp*-$SCORE*.dat | perl -ane 'if($_ =~ /^(\w+)\//) {print "$1 ";}else{print if $_ =~ /^'$SUBS'\t/}'
