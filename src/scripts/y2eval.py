#!/usr/bin/env python

from optparse import OptionParser
from collections import defaultdict as dd
import gzip
from random import choice, seed
import sys

#argparse.ArgumentParser(description='Find x clustering from wordsub pairs and y clustering.')
parser = OptionParser()
parser.add_option('-p', '--pairs', dest="pairs", help='wordsub output')
parser.add_option('-n', '--nsub', dest="nsub", help='number of substitutes per token')
parser.add_option('-s', '--seed', dest="seed", help='')
(args,op) = parser.parse_args()

assert args.pairs and args.nsub and args.seed

nsub = int(args.nsub)
seed(int(args.seed))

f = args.pairs
if f.endswith('.gz'):
    f = gzip.open(f)
else:
    f = open(f)

pairs = []
for line in f:
    line = line.strip().split("\t")
    pairs.append((line[0], line[1]))
f.close()

cluster = {}
for line in sys.stdin:
    line = line.strip().split("\t")
    cluster[line[0]] = line[1]

n = len(pairs) / nsub
for i in xrange(n):
    counts = dd(int)
    for j in xrange(nsub):
        w, s = pairs[j * n + i]
        counts[cluster[s]] += 1
    max_key = max(counts.itervalues())
    print choice(filter(lambda x: counts[x] == max_key, counts.iterkeys()))
