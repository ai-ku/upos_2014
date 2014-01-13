#!/usr/bin/env python

import sys, gzip, random
from optparse import OptionParser
from collections import defaultdict as dd

#parser = argparse.ArgumentParser(description='Finds unique x-y pairs and concatenates their vectors. Requires wkmeans output to stdin.')

parser = OptionParser()
parser.add_option('-p', '--pairs', help='wordsub output', dest="pairs")
parser.add_option('-s', '--seed', help='', dest="seed")
parser.add_option('-n', '--nsub', help='number of substitutes', dest="nsub")
(args, op) = parser.parse_args()

random.seed(int(args.seed))
repeat = int(args.nsub)

if args.pairs.endswith('.gz'):
    f = gzip.open(args.pairs)
else:
    f = open(args.pairs)

pairs = []
for line in f:
    line = line.strip().split("\t")
    pairs.append("%s_%s" % (line[0], line[1]))
f.close()

pair_clusters = {}
for line in sys.stdin:
    line = line.strip().split("\t")
    pair_clusters[line[0]] = line[1]

n = len(pairs) / repeat
for i in xrange(n):
    cluster_counts = dd(int)
    for j in xrange(repeat):
        cluster_counts[pair_clusters[pairs[i + j * n]]] += 1
    max_count = max(cluster_counts.itervalues())
    print random.choice(filter(lambda x: x[1] == max_count, cluster_counts.iteritems()))[0]
