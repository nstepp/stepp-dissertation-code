#!/bin/bash


for graph in 1 2 3; do
	for edge in `seq 1 10`; do
		for neg in `seq 1 10`; do
			mpirun -np 4 octave --eval "cd /home/stepp/academic/uconn/psyc/dissertation/src/lsm; doxcovs_mpi_chunk('500nodes/graphset$graph/sim-$edge-$neg-ts.txt');"
			mv xcstats.mat "analysis/xcstats-set$graph-$edge-$neg.mat"
		done
	done
done


