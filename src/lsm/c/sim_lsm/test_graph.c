/* Test sparse graph
 * $Id: test_graph.c 638 2010-11-22 04:24:21Z stepp $
 */

#include <stdio.h>
#include <stdlib.h>
#include "sparse_graph.h"



int main()
{
	int i;
	double weights1[4] = {1.0,2.0,3.0,4.0};
	double weights2[4] = {4.5,3.5,2.5,1.5};
	char *data_str;
	arc_t *arc;
	sparse_graph_t *graph = graph_init(10, 4, free);

	// Allocate some node data to make sure
	// it's free'd later.
	for( i=0; i<10; i++ ) {
		data_str = malloc(3);
		snprintf(data_str, 3, "%d", i);
		graph->nodes[i].data = data_str;
	}

	// make some arcs
	graph_add_arc(graph,1,4,1,weights1);
	graph_add_arc(graph,2,3,1,weights1);
	graph_add_arc(graph,5,1,1,weights1);
	graph_add_arc(graph,5,4,2,weights1);
	arc = graph_add_arc(graph,3,4,3,weights1);
	graph_add_arc(graph,4,3,2,weights1);
	graph_add_arc(graph,3,2,1,weights1);
	graph_add_arc(graph,2,5,1,weights1);

	// change one
	graph_alter_arc_weights(graph, arc, weights2);

	graph_print_dot(graph);

	graph_free(graph);

	return 0;

}

