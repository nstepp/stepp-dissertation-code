/*
 * General resevoir computing simulator
 *
 * $Id: main.c 638 2010-11-22 04:24:21Z stepp $
 *
 */

// for the GNU basename
#define _GNU_SOURCE

#ifdef DO_MPI
#include <mpi.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <getopt.h>
#include <errno.h>
#include "config.h"
#include "sparse_graph.h"
#include "dynamics.h"
#include "build_network.h"

void help(void);

int main(int argc, char *argv[])
{
	int opt = 0, option_index = 0;
	//FILE *gout;
	sparse_graph_t *graph;
	config_t config;

	struct option long_options[] = {
		{"input-nodes", 1, 0, 'n'},
		{"graph-file", 1, 0, 'i'},
		{"time", 1, 0, 't'},
		{"dt", 1, 0, 'd'},
		{"output-prefix", 1, 0, 'o'},
		{0,0,0,0}
	};


	#ifdef DO_MPI
	int rank, size;

	MPI_Init(&argc, &argv);

	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	#endif


	// Process command line
	memset(&config, 0, sizeof(config));
	while( (opt = getopt_long(argc, argv, "n:i:t:d:o:",
		    long_options, &option_index)) != -1 ) {

		config.processed++;
		errno = 0;

		switch( opt ) {
			case 'n':
				config.input_nodes = (int)strtol(optarg, NULL, 10);
				if( errno ) {
					perror("nodes");
					exit(1);
				}
				if( config.input_nodes <= 0 ) {
					fprintf(stderr, "input_nodes must be a positive integer\n");
					exit(1);
				}
				break;
			case 'i':
				strncpy(config.input_filename, optarg, PATH_MAX-1);
				break;
			case 't':
				config.time = strtod(optarg, NULL);
				if( errno ) {
					perror("time");
					exit(1);
				}
				if( config.time <= 0 ) {
					fprintf(stderr, "time must be greater than zero\n");
					exit(1);
				}
				break;
			case 'd':
				config.dt = strtod(optarg, NULL);
				if( errno ) {
					perror("dt");
					exit(1);
				}
				if( config.time <= 0 ) {
					fprintf(stderr, "dt must be greater than zero\n");
					exit(1);
				}
				break;
			case 'o':
				strncpy(config.output_prefix, basename(optarg), PATH_MAX-MAX_SUFFIX-1);
				snprintf(config.graph_filename, PATH_MAX-1, "%s-nodes.txt", config.output_prefix);
				snprintf(config.ts_filename, PATH_MAX-1, "%s-ts.txt", config.output_prefix);
				break;
			default:
				printf("opt = 0x%x?\n", opt);
				help();
				exit(1);
		}
	}


	graph = build_network(&config);

	fprintf(stderr, "Built graph: %d nodes, %ld arcs\n", graph->num_nodes, graph->num_arcs);

	#if 0
	gout = fopen(config.graph_filename, "w");
	fprintf(gout, "nodes: %d\n", graph->num_nodes);
	fprintf(gout, "time: %f ms\n", config.time);
	fprintf(gout, "dt: %f ms\n", config.dt);
	fprintf(gout, "output prefix: %s\n", config.output_prefix);
	fflush(gout);
	#endif

	sim(&config, graph);

	#if 0
	for( i=0; i<graph->num_nodes; i++ ) {
		fprintf(gout, "********** Node %d **********\n", i);
		graph_print_node_arcs(gout, graph, i);
	}
	fclose(gout);
	#endif

	#ifdef DO_MPI
	MPI_Finalize();
	#endif

	graph_free(graph);

	return 0;
}

void help(void)
{

	printf("LSM Sim - Nigel Stepp <stepp@atistar.net>\n\n");
	printf("-n --input-nodes\t Number of nodes that will receive input\n");
	printf("-i --graph-file\t File containing tab-delimited adjacency matrix\n");
	printf("-t --time\t\t Simulation time\n");
	printf("-d --dt\t\t\t Simulation time step\n");
	printf("-o --output-prefix\t Prefix for output files\n\n");

}

