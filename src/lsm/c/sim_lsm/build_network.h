#ifndef _BUILD_NETWORK_H
#define _BUILD_NETWORK_H

// $Id: build_network.h 638 2010-11-22 04:24:21Z stepp $

#include "config.h"
#include "sparse_graph.h"

int read_adj_matrix(FILE *input_file, int ***adj_matrix);
sparse_graph_t *build_network(config_t *config);


#endif

