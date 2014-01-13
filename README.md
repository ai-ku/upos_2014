INSTRUCTIONS FOR UPOS               (c) Mehmet Ali Yatbaz, Deniz Yuret, 21-May-2014

TERMS:

Please see the file LICENSE for terms of use.  The relevant paper:

Mehmet Ali Yatbaz, Enis Sert, and Deniz Yuret.  2012.  Learning
Syntactic Categories Using Paradigmatic Representations of Word
Context.  EMNLP 2012.


Mehmet Ali Yatbaz, Enis Sert, and Deniz Yuret. (Under review)  Unsupervised
Instance-Based Part of Speech Induction Using Probable Substitutes

DIRECTORY STRUCTURE:

data	- training and test data
papers	- directory for published/working papers
bin	- directory for binaries, please put this in your PATH
run	- directory for running language experiments
run/Makefile	- explains everything
run/[LanguageTag]/Makefile - Language specific parameters
src/dist	- code to find knn for substitute vectors
src/fastsubs	- code to find most likely substitutes
src/morfessor	- unsupervised morphology code by Creutz et al.
src/scode	- code to find a low dimensional co-occurence embedding
src/wkmeans	- instance weighted kmeans clustering algorithm
src/scripts	- various utility scripts

Some of the src subdirectories need to be cloned from github.  The
data of each language will be separately downloaded. 

INSTALLATION:

1. Untar the src and data archives (or clone them from github).
2. These should create a top level directory called upos.
3. Add upos/bin to your PATH.
4. Make sure the ngram-count binary from srilm is in your PATH.
5. cd upos/run/[LanguageTag]; make bin - compiles and fills the bin directory.

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

cd upos/run/[LanguageTag]; make bin; make # compiles and puts symlinks in bin directory

make [LanguageTag].vocab.gz	# time=??? - prepares the LM vocabulary
make [LanguageTag].lm.gz		# time=??? - creates a 4-gram LM
make [LanguageTag].sub.gz		# time=??? - finds most likely substitutes

make idis.[LanguageTag].out     # runs the word and instance experiments without features
make idis+o.[LanguageTag].out   # runs the experiments with orhtographic features
make idis+om.[LanguageTag].out  # runs the experiments with orhtographic and morphologic features

Other Makefile targets are for running bulk experiments to generate
the tables and graphs in the paper.  Each setting is run 10 times with
different random seeds to generate the error bars.

