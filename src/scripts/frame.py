#!/usr/bin/env python

import sys
import gzip

frame = sys.argv[1]

for line in gzip.open(sys.argv[2]):
    l = line.strip().split()
    if frame == "rbi":
        for i in range(len(l)):
            if i == len(l)-1:
                print l[i]+"\t"+"<\s>"
            else:
                print l[i]+"\t"+l[i+1]
    elif frame == "lbi":
        for i in range(len(l)):
            if i == 0:
                print l[i] + "\t<s>"
            else:
                print l[i] + "\t"+l[i-1]
    elif frame == "fle":
        for i in range(len(l)):
            bf,af = "",""
            if i == 0:
                bf = "<s>"
            else:
                bf = l[i-1]
            if i == len(l) - 1:
                af = "<\s>"
            else:
                af = l[i+1]
            print l[i]+"\t"+bf+"\t"+af
    elif frame == "fre":
        for i in range(len(l)):
            bf,af = "",""
            if i == 0:
                bf = "<s>"
            else:
                bf = l[i-1]
            if i == len(l) - 1:
                af = "<\s>"
            else:
                af = l[i+1]
            print l[i]+"\t"+bf+":"+af
    
