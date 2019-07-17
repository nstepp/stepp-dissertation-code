# pointertrack

Using a combination of the Psychophysics Toolbox and Simulink, this code sets up a Galaga-like game where the target to hit
is controled by a dynamical system. The target is constrained to the top of the screen, and the user's ship is constrained
to the bottom. The ship is controlled by moving the pointer, either via mouse or tablet.

The primary matlab script to run is `experiment2_loop.m`. Aftwards, `analyze_all_subjs.m` processes the results.
Other scripts are support for those two.

Finally, instructions for running the experiment can be found rendered from the LaTeX in `instructions`.
