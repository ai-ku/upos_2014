#!/usr/bin/env python

import sys, gzip #argparse
from optparse import OptionParser
from collections import defaultdict as dd

parser = OptionParser()
#parser = argparse.ArgumentParser(description='Finds unique x-y pairs and concatenates their vectors. Requires scode output to stdin.')
parser.add_option('-p', '--pairs', help='wordsub output', dest="pairs")
(args, op) = parser.parse_args()

if args.pairs.endswith('.gz'):
    f = gzip.open(args.pairs)
else:
    f = open(args.pairs)

pairs = dd(int)
for line in f:
    line = line.strip().split("\t")
    pairs[(line[0], line[1])] += 1

scode_x = {}
scode_y = {}
for line in sys.stdin:
    if line.startswith('0:'):
        add_to = scode_x
    elif line.startswith('1:'):
        add_to = scode_y
    line = line[2:].strip().split("\t")
    add_to[line[0]] = "\t".join(line[2:])

for pair, count in pairs.iteritems():
    word, sub = pair
    print "%s_%s\t%d\t%s\t%s" % (word, sub, count, scode_x[word], scode_y[sub])
