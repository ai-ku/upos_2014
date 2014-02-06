### Language setup files:
#Tag of language
LANGUAGE=bgm
LANGUAGE_REPO_NAME=upos-${LANGUAGE}-data.git
LANGUAGE_REPO=https://github.com/ai-ku/${LANGUAGE_REPO_NAME}
LANGUAGE_REPO_TAG=

#Vocabulary threshold
LM_VOCAB=2

#Number of induced clusters
LANG_CL=13

#Number of test instances of [LANGUAGE] We need to fix this!!
NTEST=118424

#Add feature for punctuation marks
DIS_FEAT_OPT=-p

#Get data
all:	
		test -e ${LANGUAGE}.tok.gz ||	make get_data

get_data:
	(git clone ${LANGUAGE_REPO}; cd upos-${LANGUAGE}-data; git checkout ${LANGUAGE_REPO_TAG})
	mv upos-${LANGUAGE}-data/* .
	rm -rf upos-${LANGUAGE}-data

#Experiments
include ../Makefile
