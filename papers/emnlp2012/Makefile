### 1. GENERAL SETUP

### 1.1 BIN INSTALLATION
bin:
	cd ../bin; make

### 1.2 COMMON OPTIONS
export PATH := ../bin:${PATH} # Binaries in the bin directory
SEED=1  # Random seed
NCPU=20 # Number of threads/processes to use for parallel computations


### 1.3 INPUT files:
TRAIN=../data/wsj.tok.gz # WSJ training data from CSR-3.  wc=5187874 126170376 690948662
TEST=../data/wsj.test1M.tok.gz # Test data from PTB-WSJ (wsj_0000 to wsj_2454).  wc=49208 1173766 6412448
GOLD=../data/wsj.test1M.gold.gz # Gold POS data for TEST.  wc=1222974 2347532 10255603
NTEST=1173766 # Number of test instances


### 1.4 TRAIN includes TEST, line numbers between the following two should be excluded:
TESTHEAD=1560570 # The first line of PTB-WSJ in TRAIN (same as first line of TEST)
TESTTAIL=1613710 # The last line of PTB-WSJ in TRAIN (last line of TEST is 1612868)
GETTRAIN=zcat ${TRAIN} | perl -ne 'print if ($$. < ${TESTHEAD} || $$. > ${TESTTAIL})'


### 2. COMMON FILES

### 2.1 GOLD answers:

wsj.words.gz: ${GOLD}  ## time=1s, wc=1173766 1173766 6412448
	zcat $< | perl -lane 'print $$F[0] if /\S/' | gzip > $@

wsj.pos.gz: ${GOLD}  ## time=1s, wc=1173766 1173766 3793947
	zcat $< | perl -lane 'print $$F[1] if /\S/' | gzip > $@

### 2.2 SRILM options:
LM_NGRAM=4  # n-gram order
LM_VOCAB=20 # words seen less than this in GETTRAIN will be replaced with <unk>
LM_MTYPE=i686-m64 # architecture for compiling srilm

wsj.vocab.gz: ${TRAIN}  ## LM_VOCAB=20: time=1m16s, wc=78498   78498  672284
	${GETTRAIN} | ngram-count -write-order 1 -text - -write - | \
	perl -lane 'print $$F[0] if $$F[1] >= ${LM_VOCAB}' | gzip > $@

wsj.lm.gz: wsj.vocab.gz ${TRAIN} ## LM_NGRAM=4, LM_VOCAB=20: time=6m10s, wc=27427373 118077512 847912087
	${GETTRAIN} | ngram-count -order ${LM_NGRAM} -kndiscount -interpolate -unk -vocab $< -text - -lm $@


### 2.3 FASTSUBS options:
FS_NSUB=100 # go until you have this many substitutes
FS_PSUB=1.0 # or this much cumulative probability
FS_OPTIONS=-n ${FS_NSUB} -p ${FS_PSUB}

wsj.sub.gz: ${TEST} wsj.lm.gz  ## FS_NSUB=100 FS_PSUB=1: time=4h47m, wc=1222974 245817774 2350067125
	zcat $< | fastsubs ${FS_OPTIONS} wsj.lm.gz | gzip > $@


### 2.4 KNN options:
KNN=1000 # number of nearest neighbors to compute
KNN_METRIC=1 # 0=euclid, 1=cosine
KNN_OPTIONS=-k ${KNN} -d ${KNN_METRIC} -p ${NCPU}

wsj.knn.gz: wsj.sub.gz  ## KNN=1000 KNN_METRIC=1 NCPU=24: time=21h40m, wc=1173766 2348705766 18877273290
	zcat $< | preinput.py | dists ${KNN_OPTIONS} | gzip > $@


### 2.5 MORFESSOR:
# creates the segmentation file with morfessor
# -m for path to morfessor
# -p for ppl threshold
MORFESSOR=../src/morfessor
PPLTHRESH=300
wsj.segmentation.gz: wsj.words.gz # time=33m45s wc=49212  175140 1004242
	zcat $< | run-morfessor.pl -m ${MORFESSOR} -p ${PPLTHRESH} | gzip > $@


### 2.6 FEATURE-TABLE:
# creates the feature table
# -s segmentation file from morfessor
# -w tokens from wsj.test1M.gz
wsj.features.gz: wsj.segmentation.gz  # time=2s wc=32075   67894  500312
	feature-table.pl -s $< -w wsj.words.gz | gzip > $@


### 3. EXPERIMENTS WITH DEFAULT PARAMETERS

### 3.1 PREPARE INPUT FOR SCODE:

### 3.1.1 RPART options:
RPART=65536 # Number of random partitions
RP_OPTIONS=-n ${NTEST} -p ${RPART} -s ${SEED}

rpart.pairs.gz: wsj.knn.gz wsj.words.gz ## RPART=65536: time=2m56s wc=1173766 2347532 14694441
	zcat $< | rpart.pl ${RP_OPTIONS} | join.pl wsj.words.gz - | gzip > $@


### 3.1.2 WORDSUB options:
WORDSUB=12 # Number of random substitutes per word token

wordsub.pairs.gz: wsj.sub.gz	## WORDSUB=12: time=6m33s wc=14085192 28170384 151744889
	perl -le 'print "$<" for 1..${WORDSUB}' | xargs zcat | grep -v '^</s>' | wordsub -s ${SEED} | gzip > $@

### 3.1.3 BIGRAM options (needs scode -m): (Maron et.al. 2010)

bigram.pairs.gz: ${TEST} # time=1s wc=1173765 2347530 12824887
	zcat $< | perl -lne 'for $$w (split) {print "$$p\t$$w" if defined $$p; $$p=$$w;}' | gzip > $@


### 3.1.4 WORDSUB+FEATURES options:

ws+f.pairs.gz: wordsub.pairs.gz wsj.features.gz  # time=33s wc=17696772 35393544 202205021
	zcat $< | add-features.pl -f wsj.features.gz | gzip > $@


### 3.2 SCODE options:
# -r RESTART: number of restarts (default 1)                    
# -i NITER: number of iterations over data (default 50)         
# -d NDIM: number of dimensions (default 25)                    
# -z Z: partition function approximation (default 0.166)        
# -p PHI0: learning rate parameter (default 50.0)               
# -u NU0: learning rate parameter (default 0.2)                 
# -s SEED: random seed (default 0)                              
# -c: calculate real Z (default false)                          
# -m: merge vectors at output (default false)                   
# -v: verbose messages (default false)
SC_OPTIONS=-r 1 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v

rpart.scode.gz: rpart.pairs.gz	# -i 50: time=2m23s wc=49206 1328562 12218421
	zcat $< | scode -i 50 ${SC_OPTIONS} | perl -ne 'print if s/^0://' | gzip > $@

wordsub.scode.gz: wordsub.pairs.gz # -i 10: time=5m56s wc=49206 1328562 12307474
	zcat $< | scode -i 10 ${SC_OPTIONS} | perl -ne 'print if s/^0://' | gzip > $@

bigram.scode.gz: bigram.pairs.gz # -i 50: time=1m50s wc=49206 2558712 23934400
	zcat $< | scode -m -i 50 ${SC_OPTIONS} | gzip > $@

ws+f.scode.gz: ws+f.pairs.gz # -i 10: time=7m54s wc=49206 1328562 12283891
	zcat $< | scode -i 10 ${SC_OPTIONS} | perl -ne 'print if s/^0://' | gzip > $@


### 3.3 KMEANS options:
# -k number of clusters (default 2)
# -r number of restarts (default 0)
# -s random seed
# -l input file contains labels
# -w input file contains instance weights
# -v verbose output

KM_OPTIONS=-k 45 -r 128 -l -w -v -s ${SEED}

%.kmeans.gz: %.scode.gz
	zcat $< | wkmeans ${KM_OPTIONS} | gzip > $@

## With options -k 45 -r 128 -l -w -v -s ${SEED}
## bigram.kmeans.gz: time=2m33s wc=49206   98412  569430
## rpart.kmeans.gz: time=1m39s wc=49206   98412  571430
## wordsub.kmeans.gz: time=1m41s wc=49206   98412  555499
## ws+f.kmeans.gz: time=1m18s wc=49206   98412  561090

### 3.4 EVAL options:
# -m prints many-to-one (default)
# -v prints v-measure
# -g file with gold answers

%.eval: %.kmeans.gz wsj.pos.gz ## time=1s
	zcat $< | wkmeans2eval.pl -t ${TEST} | eval.pl -m -v -g wsj.pos.gz

## Eval output columns: m2o homo comp vm
## bigram.eval: 	0.740107	0.732572	0.594198	0.656169
## rpart.eval:	 	0.763245	0.746699	0.612820	0.673168
## wordsub.eval: 	0.763027	0.753380	0.617146	0.678492
## ws+f.eval:		0.801529	0.793521	0.654906	0.717581


### 4. EXPERIMENTAL RESULTS REPORTED IN (Yatbaz et.al. 2012)

plot-%.pdf: plot-%.dat
	plot-all.gp


### 4.1 RPART experiments:
RPRUN_NARGS=4 # seed, npart, ndim, z => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

rprun.out: ${TEST} wsj.knn.gz wsj.words.gz wsj.pos.gz # NCPU=16 xargs=450: time=14h58m
	rprun-args.pl | xargs -n${RPRUN_NARGS} -P${NCPU} rprun.pl > $@

plot-p.dat: rprun.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 6=y > $@

plot-d.dat: rprun.out
	cat $< | plotdata.pl 1=65536 2=x 3=0.166 6=y > $@

plot-z.dat: rprun.out
	cat $< | plotdata.pl 1=65536 2=25 3=x 6=y > $@


### 4.2 WORDSUB experiments:
WSRUN_NARGS=2 # seed, nsub => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

wsrun.out: wsj.sub.gz wsj.pos.gz  # NCPU=16 xargs=170 time=11h27m
	wsrun-args.pl | xargs -n${WSRUN_NARGS} -P${NCPU} wsrun.pl > $@

plot-s.dat: wsrun.out
	cat $< | plotdata.pl 1=x 4=y > $@


### 4.3 WORDSUB+FEATURES experiments:
WSFRUN_NARGS=2 # seed, nsub => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

ws+f-run.out: wsj.sub.gz wsj.features.gz wsj.pos.gz  # NCPU=16 xargs=10 time=1h11m mean=.8023 std=.0070
	ws+f-args.pl | xargs -n ${WSFRUN_NARGS} -P${NCPU} ws+f-run.pl > $@


### 4.4 BIGRAM experiments:
BGRUN_NARGS=1 # seed => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

bgrun.out: bigram.pairs.gz wsj.pos.gz  # NCPU=16 xargs=20 time=22m mean=.7314 std=.0096
	bgrun-args.pl | xargs -n${BGRUN_NARGS} -P${NCPU} bgrun.pl > $@


### 4.5 WKMEANS experiments:
KMRUN_NARGS=4 # seed, file, weights, nstart => wkmeans-rms, m2o, homo, comp, vm, time

kmrun.out:
	kmrun-args.pl | xargs -n${KMRUN_NARGS} -P${NCPU} kmrun.pl > $@



### 5. MAKEFILE MISC:

.PRECIOUS: wsj.lm.gz wsj.sub.gz wsj.knn.gz wsj.vocab.gz wsj.words.gz wsj.pos.gz \
           %.pairs.gz %.scode.gz %.kmeans.gz \
           rprun.out wsrun.out kmrun.out bgrun.out

clean:
	-rm -i wsj.lm.gz wsj.sub.gz wsj.knn.gz rprun.out wsrun.out kmrun.out bgrun.out
	-rm wsj.vocab.gz wsj.words.gz wsj.pos.gz
	-rm *.pairs.gz *.scode.gz *.kmeans.gz
	cd ../bin; make clean
	cd ../src; make clean

SRC=upos/LICENSE upos/README upos/bin/Makefile upos/run/Makefile upos/src

tgz:
	cd ../..; tar --exclude=RCS --exclude=*.o --exclude=upos/src/srilm -cvzf upos.src.tgz ${SRC}
	cd ../..; tar cvzf upos.data.tgz upos/data
