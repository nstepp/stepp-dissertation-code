# Makefile for TC-Circuit simulation
# $Id: Makefile 30164 2010-10-07 22:32:56Z ndstepp $

CC = gcc
#CFLAGS = -g -Wall
#CFLAGS = -g -pg -fprofile-arcs -ftest-coverage -Wall #-DDEBUG
CFLAGS = -O2 -Wall
#CC = mpicc
LIBS = -lm
OBJS = build_network.o sparse_graph.o dynamics.o main.o

lsm: $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) $^ -o lsm

test_neuron: test_neuron.o neuron.o
	$(CC) $(CFLAGS) $(LIBS) $^ -o test_neuron

test_graph: test_graph.o sparse_graph.o
	$(CC) $(CFLAGS) $(LIBS) $^ -o test_graph

test_izhi: test_izhi.o neuron.o sparse_graph.o izhi_params.o izhi_diff.o
	$(CC) $(CFLAGS) $(LIBS) $^ -o test_izhi

test_build_network: test_build_network.o build_network.o sparse_graph.o
	$(CC) $(CFLAGS) $(LIBS) $^ -o test_build_network

clean:
	rm -f *.o *.gcda *.gcov *.gcno lsm test_neuron test_graph test_build_network test_izhi

%.o: %.c
	$(CC) $(CFLAGS) -c $<

