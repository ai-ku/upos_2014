all: kmedoids

clustering.o: clustering.cpp clustering.h
	g++ -Wall -O3 -std=gnu++0x -c $< -lm

kmedoids:  kmedoids.cpp clustering.o
	g++ -Wall -O3 -std=gnu++0x -o $@ clustering.o $< -lm
