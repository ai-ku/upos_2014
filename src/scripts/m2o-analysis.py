#!/usr/bin/env python
# # Sample Usage:
# # ./m2o-analysis.py enw.words.gz enw.pos.gz 
# # > perp>1.75
# # dance	1.75	12
# # Crowd	1.75	8
# # meltdown	1.75	4
# # Personnel	1.75	4
# # ...
# # >
# #
from collections import defaultdict as dd
import gzip
from itertools import izip
import math
import re
import sys

def read_file(name):
    if name.endswith('.gz'):
        f = gzip.open(name)
    elif name == "-":
        f = sys.stdin
    else:
        f = open(name)
    l = f.readlines()
    f.close()
    return l

def m2o_mapping(cluster, pos):
    pos_counts = dd(lambda: dd(int))
    for c, p in izip(cluster, pos):
      pos_counts[c][p] += 1
    mapping = {}
    for c, pc in pos_counts.itervalues():
        mapping[c] = max(pc.iterkeys(), key=lambda x: pc[x])
    return mapping

def m2o_score(cluster, pos, mapping):
    match = 0
    for c, p in izip(cluster, pos):
        if mapping[c] == p:
            match += 1
    return float(match) / len(cluster)

def entropy(vec):
    s = sum(vec)
    return sum(-math.log(float(v) / s, 2) * (float(v) / s) for v in vec)

def perplexity(word, pos):
    pos_counts = dd(lambda: dd(int))
    for w, p in izip(word, pos):
        pos_counts[w][p] += 1
    perp = {}
    counts = {}
    for w, pos_count in pos_counts.iteritems():
        counts[w] = sum(pos_count.itervalues())
        perp[w] = 2 ** entropy(pos_count.values())
    return perp, counts

word = read_file(sys.argv[1])
pos = read_file(sys.argv[2])
assert len(word) == len(pos)

clusters = {}
for f in sys.argv[3:]:
    clusters[f] = read_file(f)
    assert len(clusters[f]) == len(word)

perp, counts = perplexity(word, pos)

mappings = {}
for c, f in clusters.iteritems():
    mappings[c] = m2o_mapping(f, pos)
    print "%s\t%.2f" % (c, 100 * m2o_score(mappings[c]))

num = 1.75 
for w, p in sorted(filter(lambda x: x[1] > num, perp.iteritems()), key=lambda x: x[1]):
    print "%s\t%.2f\t%d" % (w.strip(), p, counts[w])

user = raw_input('> ') + "\n"
while user != "\n":
    if re.search("perp\s*>\s*(.*)", user):
        try:
            num = float(re.search("perp\s*>\s*(.*)", user).group(1))
            for w, p in sorted(filter(lambda x: x[1] > num, perp.iteritems()), key=lambda x: x[1]):
                print "%s\t%.2f\t%d" % (w.strip(), p, counts[w])
        except:
            print "Bad number."
    else:
        matches = dd(list)
        for i in xrange(len(word)):
            if word[i] == user:
                for c, f in clusters.iteritems():
                    matches[c].append(f[i])
        if len(matches) == 0:
            print "No such word."
        else:
            for c, f in clusters.iteritems():
                print "%s\t%.2f" % (c, 100 * m2o_score(mappings[c]))
    user = raw_input('> ') + "\n"

print "Happy Happy Joy Joy."
