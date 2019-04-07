/* $Id: dynamics.c 638 2010-11-22 04:24:21Z stepp $
 *
 * Functions implementing different node dynamics.
 */

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "config.h"
#include "sparse_graph.h"
#include "dynamics.h"

dynstate_t *dynstate_init(int nstates, void *state_data)
{

	dynstate_t *dynstate;

	dynstate = malloc(sizeof(dynstate_t));

	if( !dynstate ) {
		fprintf(stderr, "dynstate_init: Could not allocate state container\n");
		exit(1);
	}


	dynstate->nstates = nstates;
	dynstate->states = calloc(nstates, sizeof(double));
	dynstate->dstates = calloc(nstates, sizeof(double));

	if( !dynstate->states || !dynstate->dstates ) {
		fprintf(stderr, "dynstate_init: Could not allocate state vectors\n");
		exit(1);
	}

	memset(dynstate->states, 0, nstates * sizeof(double));
	memset(dynstate->dstates, 0, nstates * sizeof(double));

	dynstate->rk4_states = rk4_init(nstates);

	dynstate->state_data = state_data;

	return dynstate;
}

void dynstate_free(dynstate_t *dynstate)
{

	if( !dynstate ) {
		return;
	}

	if( dynstate->states ) {
		free(dynstate->states);
		dynstate->states = NULL;
	}
	if( dynstate->dstates ) {
		free(dynstate->dstates);
		dynstate->dstates = NULL;
	}

	rk4_free_states(dynstate->rk4_states);
	dynstate->rk4_states = NULL;

	free(dynstate);
}

void sim(config_t *config, sparse_graph_t *graph)
{
	int i;
	double t, dt, sim_time;
	double params[5];
	FILE *nout;
	dynstate_t *node_states, *input_states;
	decaysum_data_t decaysum_data;

	dt = config->dt;
	sim_time = config->time;

	nout = fopen(config->ts_filename, "w");

	// Set up the node dynamics context
	decaysum_data.graph = graph;
	decaysum_data.input_nodes = config->input_nodes;
	decaysum_data.input_val = 0;
	node_states = dynstate_init(graph->num_nodes, &decaysum_data);

	// Chaotic spring parameters
	// Taken from Stepp, N. (2009). Exp. Brain Res.
	// alpha, beta, a, b, c
	params[0] = 100;
	params[1] = 0.3;
	params[2] = 0.1;
	params[3] = 0.1;
	//params[4] = 14.0;
	params[4] = 11.0;
	input_states = dynstate_init(STATES_CHAOTICSPRING, params);

	// Initial conditions for the input system
	// Taken from Stepp, N. (2009). Exp. Brain Res.
	input_states->states[0] = 1.0;
	input_states->states[1] = 0.0;
	input_states->states[2] = 19.0;
	input_states->states[3] = 3.432;
	input_states->states[4] = 20.9;

	// Output intial conditions.
	fprintf(nout, "%lf\t", 0.0);
	for( i=0; i<STATES_CHAOTICSPRING; i++ ) {
		fprintf(nout, "%lf\t", input_states->states[i]);
	}
	for( i=0; i<graph->num_nodes; i++ ) {
		fprintf(nout, "%lf\t", node_states->states[i]);
	}
	fprintf(nout, "\n");

	for( t = dt; t < sim_time; t += dt ) {
		
		sim_step(t, config, graph, node_states, input_states);

		fprintf(nout, "%lf\t", t);
		for( i=0; i<STATES_CHAOTICSPRING; i++ ) {
			fprintf(nout, "%lf\t", input_states->states[i]);
		}
		for( i=0; i<graph->num_nodes; i++ ) {
			fprintf(nout, "%lf\t", node_states->states[i]);
		}
		fprintf(nout, "\n");
	}

	dynstate_free(node_states);
	dynstate_free(input_states);

	fclose(nout);
}


void sim_step(double t, config_t *config, sparse_graph_t *graph, dynstate_t *node_states, dynstate_t *input_states)
{
	decaysum_data_t *decaysum_data;

	// Input signal
	rk4_deriv(t, config->dt, chaoticspring_deriv, input_states);
	rk_step(input_states->states, input_states->nstates, config->dt, input_states->dstates, input_states->states);

	// Poke in the new input state
	decaysum_data = (decaysum_data_t *)(node_states->state_data);
	decaysum_data->input_val = input_states->states[0];

	// calculate deltas for all nodes
	rk4_deriv(t, config->dt, decaysum_deriv, node_states);

	// Apply deltas
	rk_step(node_states->states, graph->num_nodes, config->dt, node_states->dstates, node_states->states);

}


// Fourth order Runge-Kutta Method.

rk4_states_t *rk4_init(int nstates)
{
	int i;
	rk4_states_t *rk4_states;
	double *space;

	rk4_states = malloc(sizeof(rk4_states_t));
	if( !rk4_states->states ) {
		fprintf(stderr, "rk4_init: cannot allocate RK states\n");
		exit(1);
	}


	// We are allocating everything at once to try our best to
	// be cache friendly
	
	space = calloc(5 * nstates, sizeof(double));
	if( !space ) {
		fprintf(stderr, "rk4_init: cannot allocate RK state space\n");
		exit(1);
	}
	memset(space, 0, 5 * nstates * sizeof(double));

	rk4_states->states = space;

	for( i=0; i<4; i++ ) {
		rk4_states->k_states[i] = space + (i+1) * nstates;
	}

	return rk4_states;
}

void rk4_free_states(rk4_states_t *rk4_states)
{
	if( !rk4_states ) {
		return;
	}

	if( rk4_states->states ) {
		free(rk4_states->states);
		rk4_states->states = NULL;
	}

	free(rk4_states);
}

// This computes the Runge-Kutta weighted average slope.
void rk4_deriv(double t, double step, rk_deriv_t f, dynstate_t *dynstate)
{

	int i, j, rk_coef[4] = {1, 2, 2, 1};
	int nstates;
	double half_step = step/2;
	double *states, *dstates, *tmp_states;
	double **ks;
	void *data;

	if( !dynstate ) {
		fprintf(stderr, "rk4_deriv: null state info\n");
		exit(1);
	}

	// Pre-fetch some state info
	tmp_states = dynstate->rk4_states->states;
	ks = dynstate->rk4_states->k_states;
	states = dynstate->states;
	dstates = dynstate->dstates;
	nstates = dynstate->nstates;
	data = dynstate->state_data;

	// Compute intermediate derivatives
	f(t, states, data, ks[0]);

	rk_step(states, nstates, half_step, ks[0], tmp_states);
	f(t + half_step, tmp_states, data, ks[1]);

	rk_step(states, nstates, half_step, ks[1], tmp_states);
	f(t + half_step, tmp_states, data, ks[2]);

	rk_step(states, nstates, step, ks[2], tmp_states);
	f(t + step, tmp_states, data, ks[3]);

	// Take the RK4 weighted average
	for( i=0; i<nstates; i++ ) {
		dstates[i] = 0;
	}
	for( i=0; i<4; i++ ) {
		for( j=0; j<nstates; j++) {
			dstates[j] += rk_coef[i] * ks[i][j];
		}
	}
	for( i=0; i<nstates; i++ ) {
		dstates[i] /= 6.0;
	}

}

// Do the integration step given states and derivatives
void rk_step(double *states, int nstates, double step, double *dstates, double *next_states)
{
	int i;

	for( i=0; i<nstates; i++ ) {
		next_states[i] = states[i] + step * dstates[i];
	}

}


/*
 * Derivative Functions
 *
 * Each derivative function takes
 *  - time
 *  - n element state vector
 *  - m element parameter vector
 * and outputs an n element vector of derivatives.
 *
 * The signature of these functions must be
 *   void deriv(double t, double *states, double *data, double *dstates)
 *
 * It is assumed that each derivative function knows n and m for itself.
 */


// Decay + Summation
void decaysum_deriv(double t, double *states, void *data, double *dstates)
{
	int i, nstates, input_nodes;
	double input_total, input_val, arc_weight;
	decaysum_data_t *decaysum_data;
	sparse_graph_t *graph;
	arc_t *arc;

	decaysum_data = (decaysum_data_t *)data;
	graph = decaysum_data->graph;
	nstates = graph->num_nodes;
	input_nodes = decaysum_data->input_nodes;
	input_val = decaysum_data->input_val;

	for( i=0; i<nstates; i++ ) {
		arc = graph->nodes[i].arcs;

		input_total = 0;
		while( arc ) {
			arc_weight = *(arc->state);
			input_total += arc_weight * states[arc->from_node->id];

			arc = arc->next;
		}

		if( i < input_nodes ) {
			input_total += input_val;
		}

		dstates[i] = -1 * states[i] + tanh(input_total);
	}

}


// Chaotic spring function
// Usual linear spring equations, except
// with a stiffness given by the Roessler
void chaoticspring_deriv(double t, double *states, void *data, double *dstates)
{
	double x1, x2, x3, x4, x5;
	double a, b, c, alpha, beta;
	double *params = (double *)data;

	x1 = states[0];
	x2 = states[1];
	x3 = states[2];
	x4 = states[3];
	x5 = states[4];

	alpha = params[0];
	beta = params[1];
	a = params[2];
	b = params[3];
	c = params[4];

	dstates[0] = x2;

	#if 1
	dstates[1] = M_2PI * (x3/alpha + beta);
	dstates[1] *= dstates[1];
	dstates[1] *= -x1;

	#else

	dstates[1] = -x1;

	#endif

	dstates[2] = -x4 - x5;
	dstates[3] = x3 + a * x4;
	dstates[4] = b + x5 * (x3 - c);

}

