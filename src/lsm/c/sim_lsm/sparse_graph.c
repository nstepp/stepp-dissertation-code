/*
 * Sparse Graph
 * Graph implemented with arc lists as opposed
 * to a full adjacency matrix.
 *
 * Because we are concerned with *incoming* arcs,
 * we maintain lists of these instead of the usual
 * outgoing arcs.
 *
 * $Id: sparse_graph.c 638 2010-11-22 04:24:21Z stepp $
 */


#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "sparse_graph.h"



sparse_graph_t *graph_init(int num_nodes, int states_per_arc, void (*free_fn)(void *))
{
	int i;

	sparse_graph_t *new_graph = (sparse_graph_t *)malloc(sizeof(sparse_graph_t));

	if( !new_graph ) {
		fprintf(stderr, "Could not allocate graph\n");
		exit(1);
	}

	if( num_nodes < 2 ) {
		fprintf(stderr, "Init graph with too few nodes\n");
		exit(1);
	}

	new_graph->num_nodes = num_nodes;
	new_graph->num_arcs = 0;
	new_graph->states_per_arc = states_per_arc;
	new_graph->nodes = calloc(num_nodes, sizeof(node_t));
	new_graph->node_data_free_fn = free_fn;
	
	for( i=0; i<num_nodes; i++ ) {
		new_graph->nodes[i].id = i;
		new_graph->nodes[i].data = NULL;
		new_graph->nodes[i].arcs = NULL;
	}
	
	if( !new_graph->nodes ) {
		fprintf(stderr, "Could not allocate node list\n");
		exit(1);
	}

	return new_graph;
}

arc_t *graph_add_arc(sparse_graph_t *graph, int from, int to, int port, double *state)
{
	int i;
	arc_t *new_arc = (arc_t *)malloc(sizeof(arc_t));
	node_t *from_node, *to_node;

	if( !new_arc ) {
		fprintf(stderr, "Could not allocate arc\n");
		exit(1);
	}

	to_node = &graph->nodes[to];
	from_node = &graph->nodes[from];

	new_arc->state = (double *)calloc(graph->states_per_arc, sizeof(double));
	if( !new_arc->state ) {
		fprintf(stderr, "Could not allocate arc state\n");
		exit(1);
	}

	for( i=0; i<graph->states_per_arc; i++ ) {
		new_arc->state[i] = state[i];
	}

	new_arc->from_node = from_node;
	new_arc->port = port;
	new_arc->next = to_node->arcs;

	to_node->arcs = new_arc;

	graph->num_arcs++;

	return new_arc;
}

void graph_alter_arc_state(sparse_graph_t *graph, arc_t *arc, double *state)
{
	int i;
	
	for( i=0; i<graph->states_per_arc; i++ ) {
		arc->state[i] = state[i];
	}

}

void graph_print_csv(sparse_graph_t *graph)
{
	int i;
	arc_t *arcs;

	for( i=0; i<graph->num_nodes; i++ ) {

		arcs = graph->nodes[i].arcs;

		while( arcs ) {
			printf("N%d,N%d\n", arcs->from_node->id, graph->nodes[i].id);

			arcs = arcs->next;
		}
	}
}
	

void graph_print_sea(sparse_graph_t *graph)
{
	int i;
	arc_t *arcs;

	printf("Graph\n{\n");
	printf("@name=\"Sparse Graph\";\n");
	printf("@description=\"Sparse Graph\";\n");
	printf("@numNodes=%d;\n", graph->num_nodes);
	printf("@numLinks=%ld;\n", graph->num_arcs);
	printf("@numPaths=0;\n");
	printf("@numPathLinks=0;\n");

	printf("@links=[\n");

	for( i=0; i<graph->num_nodes; i++ ) {

		arcs = graph->nodes[i].arcs;

		while( arcs ) {
			printf("{ @source=%d; @destination=%d; },\n", arcs->from_node->id, graph->nodes[i].id);
			arcs = arcs->next;
		}
	}

	printf("];\n");
	printf("@paths=;\n");
	printf("@enumerations=;\n");

	// This is not a functional sea file, since it now requires the definition of
	// a spanning tree for this graph.

}

void graph_print_dot(sparse_graph_t *graph)
{
	int i;
	arc_t *arcs;

	printf("digraph G {\n");

	for( i=0; i<graph->num_nodes; i++ ) {

		arcs = graph->nodes[i].arcs;

		while( arcs ) {
			printf("N%d -> N%d [weight=%f]\n", arcs->from_node->id, graph->nodes[i].id, arcs->state[0]);

			arcs = arcs->next;
		}

	}

	printf("}\n");
}

void graph_print_node_arcs(FILE *out, sparse_graph_t *graph, int node)
{

	arc_t *arcs;

	if( !graph ) {
		return;
	}

	arcs = graph->nodes[node].arcs;

	while( arcs ) {
		fprintf(out, "%d ", arcs->from_node->id);

		arcs = arcs->next;
	}
	fprintf(out, "\n");
}


void graph_free(sparse_graph_t *graph)
{
	int i;
	arc_t *next, *arc;

	if( !graph ) {
		return;
	}
	if( !graph->node_data_free_fn ) {
		fprintf(stderr, "sparse_graph: Warning - free called on graph with no free function\n");
		fprintf(stderr, "sparse_graph: Warning - using plain free, which will probably leak something\n");
		graph->node_data_free_fn = free;
	}

	for( i=0; i<graph->num_nodes; i++ ) {
		arc = graph->nodes[i].arcs;

		if( graph->nodes[i].data ) {
			graph->node_data_free_fn(graph->nodes[i].data);
		}

		while( arc ) {
			next = arc->next;

			if( arc->state ) {
				free(arc->state);
			}

			free(arc);

			arc = next;
		}
	}

	free(graph->nodes);
	free(graph);
}

