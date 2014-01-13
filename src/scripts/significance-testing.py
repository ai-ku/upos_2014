#!/usr/bin/env python

import sys, math
from optparse import OptionParser

# python 2.6 does not have erf function
# Handbook of Mathematical Functions: with Formulas, Graphs, and Mathematical Tables formula 7.1.26
# http://stackoverflow.com/questions/457408/is-there-an-easily-available-implementation-of-erf-for-python
def erf(x):
    # save the sign of x
    sign = 1 if x >= 0 else -1
    x = abs(x)

    # constants
    a1 =  0.254829592
    a2 = -0.284496736
    a3 =  1.421413741
    a4 = -1.453152027
    a5 =  1.061405429
    p  =  0.3275911

    # A&S formula 7.1.26
    t = 1.0/(1.0 + p*x)
    y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*math.exp(-x*x)
    return sign*y # erf(-x) = -erf(x)

parser = OptionParser(usage="usage: %prog -m mean -s std < [file_of_means]")
parser.add_option("-m", "--mean", dest="mean", help="mean of the distribution")
parser.add_option("-s", "--std", dest="std", help="std of the distribution")

options, args = parser.parse_args()
if not (options.mean and options.std and float(options.std) > 0):
    parser.error("missing arguments")

mean = float(options.mean)
std = float(options.std)
for line in sys.stdin:
    line = line.split()
    m = float(line[-1])
    print "%s\t%f" % (' '.join(line[:-1]), 100*(1 - erf(abs(mean - m) / (std * (2 ** 0.5)))))
