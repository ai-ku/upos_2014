#!/usr/bin/gnuplot

set style data errorlines
set logscale x
set grid xtics mxtics ytics
#set ylabel "m2o"
unset ylabel
unset title
set terminal pdf mono size 3,2

set xlabel "number of random substitutes per word"
set xrange [0.9:100]
set yrange [0.7:0.8]
set ytics 0.01
set key top right
set output "plot-s.pdf"
plot "plot-s.dat" title "m2o"

set xlabel "number of random partitions"
set xrange [3000:400000]
set yrange [0.7:0.8]
set ytics 0.01
set key top right
set output "plot-p.pdf"
plot "plot-p.dat" title "m2o"

set xlabel "number of s-code dimensions"
set xrange [1:400]
set yrange [0.35:0.8]
set ytics 0.05
set key bottom right
set output "plot-d.pdf"
plot "plot-d.dat" title "m2o"

set xlabel "s-code Z approximation"
set xrange [0.005:4]
set yrange [0.7:0.8]
set ytics 0.01
set key top right
set output "plot-z.pdf"
plot "plot-z.dat" title "m2o"
