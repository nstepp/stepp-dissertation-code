# steersim

This code uses pygame and VisionEgg to create a very simple driving simulator.

Roads are created from a chaotic time-series (see `road[1-8].txt`), and the user is asked to control steering
in order to stay between the white lines of the road. Delay may be added to steering control inputs.

There is support code for interacting with an EyeLink II eye tracker, but unfortunately the EyeLink II code
can not be included here due to its license.
