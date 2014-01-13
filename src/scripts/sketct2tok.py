#!/usr/bin/env python

import sys

STRTAG = "<s"
ENDTAG = "</s>"
stc = None 
for l in sys.stdin:
  l = l.strip().split()
#  print >> sys.stderr, l[0]
  if l[0].startswith(STRTAG):
    stc = ""  
  elif stc != None and l[0] == ENDTAG:
    if stc != "":
      print stc
    stc = None
  elif stc != None and l[0][0] != '<' and l[0][-1] != '>':
    stc += l[0] + " "
