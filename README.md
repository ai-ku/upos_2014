INSTRUCTIONS FOR UPOS               (c) Deniz Yuret, 21-May-2012

TERMS:

Please see the file LICENSE for terms of use.  The relevant paper:

Mehmet Ali Yatbaz, Enis Sert, and Deniz Yuret.  2012.  Learning
Syntactic Categories Using Paradigmatic Representations of Word
Context.  EMNLP 2012.


DIRECTORY STRUCTURE:

data	- training and test data
papers	- directory for published/working papers
bin	- directory for binaries, please put this in your PATH
run	- directory for running experiments
run/Makefile	- explains everything
src/dist	- code to find knn for substitute vectors
src/fastsubs	- code to find most likely substitutes
src/morfessor	- unsupervised morphology code by Creutz et al.
src/scode	- code to find a low dimensional co-occurence embedding
src/scripts	- various utility scripts
src/wkmeans	- instance weighted kmeans clustering algorithm

Some of the src subdirectories need to be cloned from github.  The
data directory is available as a separate downloadable named
upos.data.tgz.

INSTALLATION:

1. Untar the src and data archives (or clone them from github).
2. These should create a top level directory called upos.
3. Add upos/bin to your PATH.
4. cd upos/run; make bin - compiles and fills the bin directory.
5. Make sure the ngram-count binary from srilm is in your PATH.

This code was tested on a Debian 6.0.1 64-bit Linux machine with the
following installed, but most other configurations should work:

srilm (1.6.0), gcc (4.4.5), perl (5.10.1), python (2.6.6), 
libc6 (2.11.2), libglib2.0-dev (2.24.2), libgsl0-dev (1.14)


RUNNING:

Here is how to use run/Makefile to run some experiments.  Timings are
from a fairly standard 2012 workstation.  You can run through the
whole sequence by saying, for example, "make bigram.eval".  But I
would at least babysit the wsj.knn.gz (required for "rpart" random
partitions) and wsj.sub.gz (required for "wordsub" random substitutes)
productions which take the biggest bulk of the time.  See the file
run/Makefile for details and more options.

cd upos/run; make bin	# compiles and puts symlinks in bin directory

make bigram.pairs.gz	# time=1s - output left word - right word pairs
make bigram.scode.gz	# time=1m50s - runs scode on bigram.pairs
make bigram.kmeans.gz	# time=2m33s - runs wkmeans on bigram.scode
make wsj.pos.gz		# time=1s - gold pos in the test set
make bigram.eval	# time=1s - compares clusters with wsj.pos

make wsj.vocab.gz	# time=1m16s - prepares the LM vocabulary
make wsj.lm.gz		# time=6m10s - creates a 4-gram LM
make wsj.sub.gz		# time=4h47m - finds most likely substitutes
make wordsub.pairs.gz	# time=1m55s - output word - random substitute pairs
make wordsub.scode.gz	# time=1m11s - runs scode on wordsub.pairs
make wordsub.kmeans.gz	# time=1m35s - runs wkmeans on wordsub.scode
make wordsub.eval	# time=1s - compares clusters with wsj.pos

make wsj.knn.gz		# time=21h40m (on 24 cores) - 1000 nearest neighbors
make wsj.words.gz	# time=1s - words in the test set
make rpart.pairs.gz	# time=2m56s - output word + partition-id pairs
make rpart.scode.gz	# time=2m23s - runs scode on rpart.pairs
make rpart.kmeans.gz	# time=1m38s - runs wkmeans on rpart.scode
make rpart.eval		# time=1s - compares clusters with wsj.pos

make wsj.segmentation.gz # time=33m45s - runs Morfessor on wsj.words.gz
make wsj.features.gz    # time=2s - combines morpho and ortho features
make ws+f.pairs.gz      # time=33s - combines wordsub.pairs with features
make ws+f.scode.gz      # time=7m54s - runs scode on ws+f.pairs
make ws+f.kmeans.gz     # time=1m18s - runs wkmeans on ws+f.scode
make ws+f.eval          # time=1s - compares clusters with wsj.pos

Other Makefile targets are for running bulk experiments to generate
the tables and graphs in the paper.  Each setting is run 10 times with
different random seeds to generate the error bars.

rprun.out		# rpart exp for changing seed, npart, ndim, z
wsrun.out		# wordsub exp for changing seed, nsub
ws+f-run.out		# ws+f exp for changing seed, nsub
bgrun.out		# bigram experiments for changing seed

plot-p.dat		# number of partitions vs. m2o
plot-d.dat		# number of dimensions vs. m2o
plot-z.dat		# Z estimate vs. m2o
plot-s.dat		# number of substitutes vs. m2o
plot-*.pdf		# Gnuplot output of the above
