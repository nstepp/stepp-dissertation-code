/*
 * $Id: test_dynamics.c 638 2010-11-22 04:24:21Z stepp $
 *
 */


#include <stdio.h>
#include <string.h>
#include "sparse_graph.h"
#include "izhi_diff.h"
#include "build_network.h"
#include "izhi_params.h"
#include "tc_adj.h"
#include "config.h"


int main()
{
	config_t config;
	sparse_graph_t *neuron_graph;
	double weights1[4] = {6,6,4,4};
	double weights2[4] = {0.1,0.1,4,4};


	neuron_graph = graph_init(5, 4, (void(*)(void*))neuron_free);



	// set neurons

	neuron_graph->nodes[0].data = neuron_new(NEURON_P23,   1);
	neuron_graph->nodes[1].data = neuron_new(NEURON_P23, 1);
	neuron_graph->nodes[2].data = neuron_new(NEURON_SS4, 1);
	neuron_graph->nodes[3].data = neuron_new(NEURON_P4,  1);
	neuron_graph->nodes[4].data = neuron_new(NEURON_P4, 1);

	// set connections

	graph_add_arc(neuron_graph, 1, 0, 0, weights1);
	graph_add_arc(neuron_graph, 2, 0, 0, weights1);
	graph_add_arc(neuron_graph, 3, 0, 0, weights1);
	graph_add_arc(neuron_graph, 4, 0, 0, weights1);
	

	graph_add_arc(neuron_graph, 2, 1, 0, weights1);
	graph_add_arc(neuron_graph, 3, 1, 0, weights1);
	graph_add_arc(neuron_graph, 4, 1, 0, weights1);
	graph_add_arc(neuron_graph, 0, 1, 0, weights1);
	
	graph_add_arc(neuron_graph, 3, 2, 0, weights1);
	graph_add_arc(neuron_graph, 4, 2, 0, weights1);
	graph_add_arc(neuron_graph, 0, 2, 0, weights1);
	graph_add_arc(neuron_graph, 1, 2, 0, weights1);

	graph_add_arc(neuron_graph, 4, 3, 0, weights1);
	graph_add_arc(neuron_graph, 0, 3, 0, weights1);
	graph_add_arc(neuron_graph, 1, 3, 0, weights1);
	graph_add_arc(neuron_graph, 2, 3, 0, weights1);

	graph_add_arc(neuron_graph, 0, 4, 0, weights2);
	graph_add_arc(neuron_graph, 1, 4, 0, weights1);

	fprintf(stderr, "Built graph: %d nodes, %ld arcs\n", neuron_graph->num_nodes, neuron_graph->num_arcs);


	// start off with some high voltage spikes
	((neuron_t *)(neuron_graph->nodes[4].data))->compartments[0].v = 60;
	((neuron_t *)(neuron_graph->nodes[3].data))->compartments[0].v = 60;
	((neuron_t *)(neuron_graph->nodes[2].data))->compartments[0].v = 60;
	((neuron_t *)(neuron_graph->nodes[1].data))->compartments[0].v = 60;
	((neuron_t *)(neuron_graph->nodes[0].data))->compartments[0].v = 60;

	memset(&config, 0, sizeof(config));
	config.num_neurons = 5;
	config.time = 500;
	config.dt = 0.2;
	config.amp1 = 1000;
	config.amp2 = 1000;
	config.bias = 1000;
	config.freq1 = .1;
	config.freq2 = .1;
	strncpy(config.graph_filename, "test-neurons.txt", PATH_MAX);
	strncpy(config.vsoma_filename, "test-vsoma.txt", PATH_MAX);
	strncpy(config.usoma_filename, "test-usoma.txt", PATH_MAX);
	strncpy(config.vcomp_filename, "test-vcomp.txt", PATH_MAX);
	strncpy(config.ucomp_filename, "test-ucomp.txt", PATH_MAX);
	strncpy(config.arcg_filename, "test-arcg.txt", PATH_MAX);
	izhi_sim(&config, neuron_graph, model_params);

	graph_free(neuron_graph);

	return 0;
}

