#ifndef _DYNAMICS_H
#define _DYNAMICS_H

// $Id: dynamics.h 638 2010-11-22 04:24:21Z stepp $

#include "config.h"
#include "sparse_graph.h"

#define STATES_CHAOTICSPRING 5
#define M_2PI 6.28318530717958647692

typedef void(*rk_deriv_t)(double, double *, void *, double *);

typedef struct rk4_states_t {
	double *states;
	double *k_states[4];
} rk4_states_t;

typedef struct dynstate_t {
	int nstates;
	double *states;
	double *dstates;
	rk4_states_t *rk4_states;
	void *state_data;
} dynstate_t;


typedef struct decaysum_data_t {
	sparse_graph_t *graph;
	int input_nodes;
	double input_val;
} decaysum_data_t;

dynstate_t *dynstate_init(int nstates, void *state_data);

void sim(config_t *config, sparse_graph_t *graph);
void sim_step(double t, config_t *config, sparse_graph_t *graph, dynstate_t *node_states, dynstate_t *input_states);

rk4_states_t *rk4_init(int nstates);
void rk4_free_states(rk4_states_t *rk4_states);
void rk4_deriv(double t, double step, rk_deriv_t f, dynstate_t *dynstate);
void rk_step(double *states, int nstates, double step, double *dstates, double *next_states);

void decaysum_deriv(double t, double *states, void *data, double *dstates);
void chaoticspring_deriv(double t, double *states, void *data, double *dstates);

#endif


