#!/usr/bin/env gnuplot
set terminal pdf mono dashed size 3,2 
set style data lines
set xlabel "tag perplexity"
set ylabel "m2o"
set output "ksmooth.pdf"
plot "ksmooth.out" using 1:2 title "word clustering", "ksmooth.out" using 1:3 title "substitute clustering"
