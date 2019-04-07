/* Test network building, using a probabilistic adjacency table
 * $Id: test_build_network.c 638 2010-11-22 04:24:21Z stepp $
 */

#include <stdio.h>
#include <string.h>
#include "config.h"
#include "sparse_graph.h"
#include "build_network.h"



int main()
{

	config_t config;
	sparse_graph_t *graph;
	char input_filename[] = "test_graph.txt";

	config.time = 1000;
	config.dt = 0.01;
	strncpy(config.input_filename, input_filename, PATH_MAX);

	graph = build_network(&config);

	graph_print_dot(graph);

	graph_free(graph);

	return 0;

}

