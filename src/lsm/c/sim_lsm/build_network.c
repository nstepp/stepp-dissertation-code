/*
 * Create a sparse graph of an LSM type resevoir
 * from an adjacency matrix
 *
 * $Id: build_network.c 638 2010-11-22 04:24:21Z stepp $
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <string.h>
#include "config.h"
#include "sparse_graph.h"


int read_adj_matrix(FILE *input_file, int ***adj_matrix)
{

	int i, ret;
	char lastch = '\0', ch = '\0';
	int num_nodes, row, col;
	double val;
	int **adj;

	// examine first line to get node count
	num_nodes = 0;
	while( ch != '\n' ) {
		ch = fgetc(input_file);

		if( ch == '\t' || (ch == '\n' && lastch != '\t') ) {
			num_nodes++;
		}

		lastch = ch;
	}

	// allocate matrix
	adj = calloc(num_nodes, sizeof(int *));
	adj[0] = calloc(num_nodes * num_nodes, sizeof(int));
	if( !adj || !adj[0] ) {
		fprintf(stderr, "read_adj_matrix: unable to allocate matrix\n");
		exit(1);
	}
	for( i=0; i<num_nodes; i++ ) {
		adj[i] = adj[0] + i * num_nodes;
	}


	rewind(input_file);

	// read in matrix
	row = 0;
	col = 0;
	while( !feof(input_file) ) {
		
		ret = fscanf(input_file, "%lf", &val);
		if( ret < 1 ) {
			break;
		}

		adj[row][col] = (int)val;

		col++;
		if( col >= num_nodes ) {
			row++;
			col = 0;
		}
	}
	
	if( row != num_nodes ) {
		fprintf(stderr, "read_adj_matrix: not a square matrix (%d != %d)\n", row, num_nodes);
		exit(1);
	}

	*adj_matrix = adj;

	return num_nodes;

}

sparse_graph_t *build_network(config_t *config)
{
	int i,j;
	int num_nodes;
	int **adj_matrix;
	double weight;
	FILE *graph_file;
	sparse_graph_t *graph;
	

	graph_file = fopen(config->input_filename, "r");

	
	num_nodes = read_adj_matrix(graph_file, &adj_matrix);

	fclose(graph_file);

	
	graph = graph_init(num_nodes, 1, free);


	for( i=0; i<num_nodes; i++ ) {
		for( j=0; j<num_nodes; j++ ) {

			if( adj_matrix[i][j] != 0 ) {
				weight = (double)adj_matrix[i][j];
				graph_add_arc(graph, i, j, 0, &weight);
			}

		}
	}

	// We are done with this now
	free(adj_matrix);

	return graph;
}

