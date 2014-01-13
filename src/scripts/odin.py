#!/usr/bin/env python

import sys
import math
from collections import defaultdict as dd
import gzip
# Args: argv1 vocab argv2 traininfile argv3 sub file
word = dd(int)
voc = dd(int)
tot = 0
print >> sys.stderr, "read vocabulary"
for l in gzip.open(sys.argv[1]): 
   l = l.strip()
   voc[l] = 1

print >> sys.stderr, "read training"
for l in gzip.open(sys.argv[2]): 
  larr = l.strip().split()
  for w in larr:
    if w in voc:
      word[w] += 1
    else: 
      word["<unk>"] += 1
    tot += 1
  word["</s>"] += 1
  tot += 1

line = 0
print >> sys.stderr, "read subs: total:", tot
for l in gzip.open(sys.argv[3]): 
  larr = l.strip().split()
  if line % 100000 == 0:
    print >> sys.stderr, ".",
  if larr[0] == '</s>':
    print l,
    continue
  subs = {}
  for i in range(1, len(larr),2):
  #  print >> sys.stderr, larr[i], word[larr[i]],larr[i+1]
    sub = math.log(word[larr[i]] * 1.0 / tot, 10) 
    subs[larr[i]] = float(larr[i + 1]) - sub  
  print larr[0],
  for s, p in sorted(subs.items(), key = lambda x: x[1], reverse=True):
    print "\t%s %.8f" % (s, p),
  print
  line += 1
