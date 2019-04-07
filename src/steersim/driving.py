#!/usr/bin/env python
"""Very simple driving simulator"""

# $Id: driving.py 737 2012-01-20 03:32:04Z stepp $

import random
import numpy
import Image, ImageDraw, ImagePath


import VisionEgg
VisionEgg.start_default_logging(); VisionEgg.watch_exceptions()
from VisionEgg.Core import *

import Simulation

doEyetrack = False
trialDuration = 60.0


VisionEgg.config.VISIONEGG_FULLSCREEN = 1
VisionEgg.config.VISIONEGG_SCREEN_W = 1024
VisionEgg.config.VISIONEGG_SCREEN_H = 768

screen = get_default_screen()

sim = Simulation.Simulation(screen)

practiceTrials = [
	(0, 0),
	(0, 0),
	(0, 0)
	]

trials = [
	(1,  0.05),
	(2,  0.10),
	(3,  0.15),
	(4,  0.20),
	(5,  0.25),
	(6,  0.30),
	(7,  0.35),
	(8,  0.40),
	(9,  0.45),
	(10, 0.50),
	(11, 0.55),
	(12, 0.60),
	(13, 0.65),
	(14, 0.70),
	(15, 0.75),
	(16, 0.80)
	]

numRoads = 8

random.seed()
random.shuffle(trials)

print trials

for trial in practiceTrials:
	sim.doSim(trial[0], 1, trialDuration, trial[1], False)


roadCounter = 0
for trial in trials:
	sim.doSim(trial[0], (roadCounter % numRoads) + 1, trialDuration, trial[1], doEyetrack)
	roadCounter = roadCounter + 1

