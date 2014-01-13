#!/usr/bin/env python

import gzip
from optparse import OptionParser
from collections import defaultdict as dd
from itertools import izip
from math import log

def read_file(name):
    if name.endswith(".gz"):
        f = gzip.open(name)
    else:
        f = open(name)
    lines = f.readlines()
    f.close()
    return lines

def m2o_mapping(clusters, pos):
    counts = dd(lambda: dd(int))
    for c, p in izip(clusters, pos):
        counts[c][p] += 1
    mapping = {}
    for c, pos in counts.iteritems():
        mapping[c] = max(pos.iterkeys(), key=lambda x: pos[x])
    return mapping

def m2o(clusters, pos, mapping):
    match = 0
    for c, p in izip(clusters, pos):
        if mapping[c] == p:
            match += 1
    return float(match) / len(clusters)

def perplexity_mapping(words, pos):
    counts = dd(lambda: dd(int))
    for w, p in izip(words, pos):
        counts[w][p] += 1
    mapping = {}
    for w, pos in counts.iteritems():
        total = sum(pos.itervalues())
        probs = map(lambda x: float(x) / total, pos.itervalues())
        entropy = sum((-p * log(p, 2) for p in probs))
        mapping[w] = 2 ** entropy
    return mapping

def perp_bins(clusters, words, perp_mapping):
    bins = dd(list)
    for w, c in izip(words, clusters):
        p = perp_mapping[w]
        bins["All"].append(c)
        # if p <= 1: bins["=1"].append(c)
        # if p > 1 and p < 2: bins["1<p<2"].append(c)
        # if p >= 2: bins[">=2"].append(c)
        if p < 1.75: bins["<1.75"].append(c)
        if p >= 1.75: bins[">=1.75"].append(c)
        # if p < 2: bins["<2"].append(c)
        # if p >= 2: bins[">=2"].append(c)
        # if p > 1   and p <= 1.5: bins["1<p<=1.5"].append(c)
        # if p > 1.5 and p <= 2:   bins["1.5<p<=2"].append(c)
        # if p > 2   and p <= 2.5: bins["2<p<=2.5"].append(c)
        # if p > 2.5 and p <= 3:   bins["2.5<p<=3"].append(c)
        # if p > 3:   bins[">=3"].append(c)
    return bins

parser = OptionParser(usage="usage: %prog -w words -p pos [files]")
parser.add_option("-w", "--words", dest="words", help="word token file")
parser.add_option("-p", "--pos", dest="pos", help="gold pos tag file")

options, args = parser.parse_args()
if not (options.words and options.pos and len(args)):
    parser.error("missing arguments")

words = read_file(options.words)
pos = read_file(options.pos)
if len(words) != len(pos):
    parser.error("words length doesn't match pos length")

clusters = []
if args[0].endswith(".gz"):
    f = gzip.open(args[0])
else:
    f = open(args[0])
for line in f:
    line = line.strip().split("\t")
    for i in xrange(len(line)):
        try: clusters[i].append(line[i])
        except: clusters.append([line[i]])
f.close()

for c in clusters:
    if len(c) != len(words):
        parser.error("words length doesn't match cluster length")


# clusters = []
# for f in args:
#     f = read_file(f)
#     if len(words) != len(f):
#         parser.error("file length doesn't match pos length")
#     clusters.append(f)

clusters_mappings = []
for clu in clusters:
    clusters_mappings.append(m2o_mapping(clu, pos))

perp_mapping = perplexity_mapping(words, pos)

pos_bins = perp_bins(pos, words, perp_mapping)
m2o_bins = dd(list)
for cluster, cluster_mapping in izip(clusters, clusters_mappings):
    bins = perp_bins(cluster, words, perp_mapping)
    for b in bins.iterkeys():
        m2o_bins[b].append(m2o(bins[b], pos_bins[b], cluster_mapping))

for b, m2os in sorted(m2o_bins.iteritems()):
    average = sum(m2os) / len(m2os)
    std = (sum(((average - x) ** 2 for x in m2os)) / len(m2os)) ** 0.5
    print "%s\t%d\t%g\t%g" % (b, len(pos_bins[b]), average, std)

# print m2o_bins

# print options
# print args
