#ifndef _CONFIG_H
#define _CONFIG_H

// $Id: config.h 638 2010-11-22 04:24:21Z stepp $

#include <limits.h>

#ifdef INPUT_SINE
 #define CONFIG_NUM 9
#else
 #define CONFIG_NUM 5
#endif

#define MAX_SUFFIX 32

typedef struct config_t {
	int processed;
	int input_nodes;
	double time;
	double dt;
	char output_prefix[PATH_MAX-MAX_SUFFIX];
	char input_filename[PATH_MAX];
	char graph_filename[PATH_MAX];
	char ts_filename[PATH_MAX];
} config_t;

#endif

