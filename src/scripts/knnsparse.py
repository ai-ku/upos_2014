#!/usr/bin/python
# calcualtes supervised weighted knn baseline from sparse format
# This code does not handle tie cases

import sys
import gzip
import pprint
import collections as col;

def map_keyfile(fname, withtags=False):
    #returns: dd:index-> word array maps:?? keys: index->key from ptb formated file
    #<s> and <\s> tags and emptylines are omitted during indexing
    dd = []
    keys = {}
    maps = col.defaultdict(lambda: col.defaultdict(int))
    for line in gzip.open(fname):
        l = line.strip().split()    
        if len(l) == 0:
            continue
        dd.append(l[0])
        maps[l[0]]["_A_"] += 1
        maps[l[0]][len(dd) - 1] = maps[l[0]]["_A_"]
        keys[len(dd) - 1] = l[1]
    return (dd,maps,keys)

def knn_dist_sparse_gz(words, keys, k, debug = False):
    if debug: print >> sys.stderr, "calculating"
    cr, wr = 0, 0
    for (r,line) in enumerate(sys.stdin, start = 0):
        ll = line.strip().split()
        ll.pop(0)
        colum = len(ll)/2
        ans = col.defaultdict(lambda: 0)
        maxv,maxi = 0,-1
        if keys[r] == "</s>":
            continue        
        for j in range(k):
            ref = int(ll[2*j])
            if ref == r:
                j -= 1
                continue
            if float(ll[2*j+1]) == 0:                
                ans[keys[ref]] += 1.0/10e-15;
            else:
                ans[keys[ref]] += 1.0/float(ll[2*j+1])
                
            if ans[keys[ref]] > maxv:
                    maxv = ans[keys[ref]]
                    maxi = keys[ref]
        if maxi == keys[r]:
            cr += 1
        else:
            wr += 1
        if debug and r % 100000 == 0:
            print >> sys.stderr, r,
            print >> sys.stderr, cr,"\t",wr, "\t", 1.0*cr /(wr+cr)
    print cr,"\t",wr, "\t", 1.0*cr /(wr+cr)

keys = map_keyfile(sys.argv[1])
knn_dist_sparse_gz(keys[0],keys[2], int(sys.argv[2]), debug=False)
