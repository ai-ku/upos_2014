#!/usr/bin/env python

# # Sample Usage
# # /work/_upos_new/run/enw[141]$ ./cluster-analysis.py enw.words.gz enw.pos.gz 
# # >>> load enw.pos.gz
# # Loaded enw.pos.gz
# # >>> load type.out.gz 
# # Loaded type.out.gz
# # >>> perp
# # -inf <= perp <= inf
# # -inf <= count <= inf
# # 1173766 (100.00%)
# # enw.pos.gz:	1
# # one-tag-per-type:	0.945642
# # type.out.gz:	0.764664

import sys, gzip, math, re
from collections import defaultdict as dd, namedtuple
from itertools import izip
from operator import itemgetter, attrgetter

def read_file(name):
    try:
        if name.endswith('.gz'):
            f = gzip.open(name)
        else:
            f = open(name)
        lines = [line.strip().split()[0] for line in f]
        f.close()
        return lines
    except:
        return None

def perplexity_and_counts(count_vec):
    total = sum(count_vec.itervalues())
    entropy = 0.0
    for c in count_vec.itervalues():
        p = float(c) / total
        entropy += -p * math.log(p, 2)
    return 2 ** entropy, total

Stat = namedtuple('Stat', ['perp', 'count'])
def data_stats(word, pos):
    counts = dd(lambda: dd(int))
    for c, p in izip(word, pos):
        counts[c][p] += 1
    stats = {}
    for c, v in counts.iteritems():
        perp, count = perplexity_and_counts(v)
        stats[c] = Stat(perp, count)
    return stats

def m2o_mapping(cluster, pos):
    counts = dd(lambda: dd(int))
    for c, p in izip(cluster, pos):
        counts[c][p] += 1
    mapping = {}
    for c, v in counts.iteritems():
        mapping[c] = max(v.iteritems(), key=itemgetter(1))[0]
    return mapping

def m2o_accuracy(cluster, pos, mapping):
    match = 0
    for c, p in izip(cluster, pos):
        if mapping[c] == p:
            match += 1
    return float(match) / len(pos)

clusters = {}
mappings = {}
word = read_file(sys.argv[1])
pos = read_file(sys.argv[2])
if (not word) or (not pos):
    print "Bad word or pos file"
    sys.exit(1)
stat = data_stats(word, pos)

clusters['one-tag-per-type'] = word
mappings['one-tag-per-type'] = m2o_mapping(word, pos)

perp = [float('-inf'), float('inf')]
count = [float('-inf'), float('inf')]

def print_with_limits():
    matches = dict(((k, []) for k in clusters.iterkeys()))
    p = []
    for i in xrange(len(word)):
        if perp[0] <= stat[word[i]].perp <= perp[1] and\
                count[0] <= stat[word[i]].count <= count[1]:
            p.append(pos[i])
            for k, v in matches.iteritems():
                v.append(clusters[k][i])
    print perp[0], "<= perp <=", perp[1]
    print count[0], "<= count <=", count[1]
    print "%d (%.2f%%)" % (len(p), float(len(p)) * 100.0 / len(word))
    for k in sorted(clusters.iterkeys()):
        print "%s:\t%g" % (k, m2o_accuracy(matches[k], p, mappings[k]))
    print " avgperp:\t%g" % (avgperp / float(len(p)))

while True:
    line = raw_input(">>> ")
    if line.startswith("load"):
        line = line.split()
        new_file = read_file(line[1])
        if new_file and len(new_file) == len(pos):
            clusters[line[1]] = new_file
            mappings[line[1]] = m2o_mapping(new_file, pos)
            print "Loaded", line[1]
        else:
            print "Bad file"

    elif line.startswith("word"):
        line = line.split()
        w = line[1]
        matches = dict(((k, []) for k in clusters.iterkeys()))
        p = []
        for i in xrange(len(word)):
            if word[i] == w:
                p.append(pos[i])
                for k, v in matches.iteritems():
                    v.append(clusters[k][i])
        print "word = %s" % w
        print "%d (%.2f%%)" % (len(p), float(len(p)) * 100.0 / len(word))
        for k in sorted(clusters.iterkeys()):
            print "%s:\t%g" % (k, m2o_accuracy(matches[k], p, mappings[k]))

    elif re.match('\s*(perp|count)\s*(<=|>=)\s*(\d+(\.\d*)?|\d*\.\d+|-?inf)\s*', line):
        m = re.match('\s*(perp|count)\s*(<=|>=)\s*(\d+(\.\d*)?|\d*\.\d+|-?inf)\s*', line)
        val = float(m.group(3))
        lim = 0
        if m.group(2) == '<=':
            lim = 1
        if m.group(1) == 'perp':
            perp[lim] = val
        else:
            count[lim] = val
        print_with_limits()

    else:
        print_with_limits()
