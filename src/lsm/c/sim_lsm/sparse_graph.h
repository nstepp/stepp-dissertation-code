#ifndef _SPARSE_GRAPH_H
#define _SPARSE_GRAPH_H


/*
 * These implement a sparse graph using arc lists
 * instead of an adjacency matrix.
 *
 * Additionally, each arc supports keeping multiple
 * states values, and multiple target ports.
 *
 * Because we are concerned with *incoming* arcs,
 * we maintain lists of these instead of the usual
 * outgoing arcs.
 *
 * $Id: sparse_graph.h 638 2010-11-22 04:24:21Z stepp $
 */

#include <stdio.h>

typedef struct arc_t {
	double *state;
	struct node_t *from_node;
	int port;
	struct arc_t *next;
} arc_t;

typedef struct node_t {
	int id;
	void *data;
	arc_t *arcs;
} node_t;

typedef struct sparse_graph_t {
	int num_nodes;
	long num_arcs;
	int states_per_arc;
	node_t *nodes;
	void (*node_data_free_fn)(void *);
} sparse_graph_t;


sparse_graph_t *graph_init(int num_nodes, int states_per_arc, void (*free_fn)(void *));
arc_t *graph_add_arc(sparse_graph_t *graph, int from, int to, int port, double *state);
void graph_alter_arc_state(sparse_graph_t *graph, arc_t *arc, double *state);
void graph_print_sea(sparse_graph_t *graph);
void graph_print_csv(sparse_graph_t *graph);
void graph_print_dot(sparse_graph_t *graph);
void graph_print_node_arcs(FILE *out, sparse_graph_t *graph, int node);
void graph_free(sparse_graph_t *graph);


#endif

