### Language setup files:
#Tag of language
LANGUAGE=enw
LANGUAGE_REPO_NAME=upos-${LANGUAGE}-data.git
LANGUAGE_REPO=http://github.com/ai-ku/${LANGUAGE_REPO_NAME}
LANGUAGE_REPO_TAG=

#Vocabulary threshold
LM_VOCAB=20
MINI_LM_VOCAB=500

#Number of induced clusters
LANG_CL=45

# Number of test instances of [LANGUAGE] We need to fix this!!
NTEST=1173766

# Add feature for punctuation marks
DIS_FEAT_OPT=

all:	
		test -e ${LANGUAGE}.tok.gz ||	make get_data

get_data:
	(git clone ${LANGUAGE_REPO}; cd upos-${LANGUAGE}-data; git checkout ${LANGUAGE_REPO_TAG})
	mv upos-${LANGUAGE}-data/* .
	rm -rf upos-${LANGUAGE}-data

include ../Makefile
