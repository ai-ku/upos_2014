all: eval.pl fastsubs dists scode wkmeans wordsub readsparse.mexa64 runsc.m runpca.m runlle.m runiso.m

### Reprository Check-out Commands
## If the latest version is required then do not set the corresponding
## tag variable.
## SCODE
SCODE_GIT_REPO=git://github.com/ai-ku/scode.git
SCODE_GIT_TAG=acl2014
## DIST
DIST_GIT_REPO=git://github.com/ai-ku/dist.git
DIST_GIT_TAG=acl2014
## WKMEANS
WKMEANS_GIT_REPO=git://github.com/ai-ku/wkmeans.git
WKMEANS_GIT_TAG=acl2014
## FASTSUBS
FASTSUBS_GIT_REPO=git://github.com/ai-ku/fastsubs.git
FASTSUBS_GIT_TAG=acl2014
###
eval.pl: check
	test -e $@ || ln -s ../src/scripts/* .

fastsubs: check
	test -e ../src/fastsubs || (cd ../src/ && git clone ${FASTSUBS_GIT_REPO} ) 
	cd ../src/fastsubs && git checkout ${FASTSUBS_GIT_TAG} && make
	test -e $@ || ln -s ../src/fastsubs/fastsubs .
	test -e subs || ln -s ../src/fastsubs/subs .
	test -e wordsub || ln -s ../src/fastsubs/wordsub .

dists: check
	test -e ../src/dists || (cd ../src/ && git clone ${DIST_GIT_REPO} ) 
	cd ../src/dist && git checkout ${DIST_GIT_TAG} && make
	test -e $@ || ln -s ../src/dist/dists .

scode: check
	test -e ../src/scode || (cd ../src/ && git clone ${SCODE_GIT_REPO} ) 
	cd ../src/scode && git checkout ${SCODE_GIT_TAG} && make
	test -e $@ || ln -s ../src/scode/scode .

wkmeans: check
	test -e ../src/wkmeans || (cd ../src/ && git clone ${WKMEANS_GIT_REPO} ) 
	cd ../src/wkmeans && git checkout ${WKMEANS_GIT_TAG} && make
	test -e $@ || ln -s ../src/wkmeans/wkmeans .


runsc.m: check
	cd ../src/spectral;
	test -e $@ || ln -s ../src/spectral/runsc.m
	test -e sc.m || ln -s ../src/spectral/sc.m

runpca.m: check
	cd ../src/pca;
	test -e $@ || ln -s ../src/pca/runpca.m

runlle.m: check
	cd ../src/lle;
	test -e $@ || ln -s ../src/lle/runlle.m
	test -e lle.m || ln -s ../src/lle/lle.m

runiso.m: check
	cd ../src/iso; make
	test -e $@ || ln -s ../src/iso/runiso.m
	test -e IsomapII.m || ln -s ../src/iso/IsomapII.m
	test -e dijkstra.mexa64 || ln -s ../src/iso/dijkstra.mexa64
	test -e dfun.m || ln -s ../src/iso/dfun.m
	test -e L2_distance.m || ln -s ../src/iso/L2_distance.m

readsparse.mexa64: check
	cd ../src/readsparse/; make
	test -e readsparse.mexa64 || ln -s ../src/readsparse/readsparse.mexa64
	test -e readsparseidx.mexa64 || ln -s ../src/readsparse/readsparseidx.mexa64

check:
	true

clean:
	-rm *.m *.pl *.py *.gp *.sh fastsubs subs dists scode wkmeans wordsub *.mexa64 *sed *~
