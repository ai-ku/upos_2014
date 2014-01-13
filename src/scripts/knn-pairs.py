#!/usr/bin/env python
#./knn-pairs.gz words-file knn-file number-of-knn
#Example
#./knn-pairs.gz enw.words.gz enw.knn.gz 10

import sys, gzip
from itertools import izip_longest

i = 0
pairs = []
knn = int(sys.argv[2])
for l1, l2 in izip_longest(gzip.open(sys.argv[1]), 
		sys.stdin,
		fillvalue=None):
	if l1 == None or l2 == None:
		sys.exit("Length mismatch of words and knn file\n")
	l1arr = l1.strip().split()
	l2arr = l2.strip().split()
	if i % 50000 == 0:
		print >> sys.stderr, ".",
	pairs.append([l1arr[0], [str(i)] + l2arr[1:2*knn+1:2]])
	i += 1
print >> sys.stderr, "Done reading files"
for k in range(knn):
	for p in pairs:	
		print "%s\t%s" % (p[0], p[1][k])
