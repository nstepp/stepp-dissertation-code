
# $Id: Simulation.py 597 2010-07-23 21:28:06Z stepp $

import numpy
import Image, ImageDraw, ImagePath
import VisionEgg
VisionEgg.start_default_logging(); VisionEgg.watch_exceptions()

from VisionEgg.Core import *
from VisionEgg.FlowControl import Presentation, FunctionController
from VisionEgg.Text import *
from VisionEgg.Textures import *
from VisionEgg.MoreStimuli import Rectangle3D

from RingBuffer import *


class SimulationState:
	def __init__(self):
		self.th = 0
		self.v = 0
		self.x = 0
		self.z = 0


class Simulation:
	def __init__(self, screen):
		self.state = SimulationState()
		self.state.v = 15
		self.screen = screen
		self.center = screen.size[0]/2.0;
		self.doneSetup = False
		self.quit = False

	def init_state(self):
		self.state.th = 0
		self.state.x = 0
		self.state.z = 0

	def wait_for_key(self,t):
		#event = pygame.event.poll()
		#while event != pygame.NOEVENT:
		#	if event == pygame.KEYDOWN:
		#		self.askForNext.quit = True
		#	event = pygame.event.poll()
		pygame.event.pump()
		if any(pygame.key.get_pressed()):
			print "Got key"
			self.askForNext.parameters.quit = True
		self.askForNext.parameters.enter_go_loop = True

	def update(self, t):

		# Estimate the current frame rate
		try:
			dt = self.frame_timer.get_average_ifi_sec()
		except RuntimeError:
			dt = 0.01

		# Map the pointer position to angular velocity of +/- 90 degrees/s
		curr_pos = pygame.mouse.get_pos()
		self.pos_ring.add(curr_pos[0])
		pos = self.pos_ring.head()
		center = self.center

		self.state.th = self.state.th + dt*(-(math.pi)/2.0 * (pos - center)/center)

		# Update steering wheel
		self.wheel.set(angle = -90.0 * (curr_pos[0] - center)/center)

		th = self.state.th
		x = self.state.x
		z = self.state.z

		self.outf.write("%f\t%u\t%u\t%u\t%f\t%f\t%f\n" % (t, curr_pos[0], curr_pos[1], pos, th, x, z))

		# this is a left handed camera transform, the right handed ones that are
		# built in to visionegg were not working for me.
		# Translate, then rotate about the y-axis by our current heading angle
		viewXfrm = numpy.matrix([
			[		 math.cos(th),		0.0,		math.sin(th),		0.0],
			[			0.0,		 1.0,			0.0,		  0.0],
			[		-math.sin(th),		0.0,		math.cos(th),		0.0],
			[-x*math.cos(th)+z*math.sin(th), 0.0, -x*math.sin(th)-z*math.cos(th), 1.0]
			])

		# Make a step in the direction of current heading
		self.state.x = x + self.state.v*dt*math.sin(-th)
		self.state.z = z - self.state.v*dt*math.cos(-th)

		self.camera_matrix.parameters.matrix = viewXfrm



	def doSim(self, trial, road, duration, tau, doEyetrack):

		# Measure sample rate in order to calculate delay buffer
		sample_rate = self.screen.measure_refresh_rate(2.0)
		print "Sample rate: " + str(sample_rate)
		#sample_rate = 60

		self.doEyetrack = doEyetrack

		self.pos_ring = RingBuffer(self.center, int(math.floor(tau * sample_rate))+1)
		print("Ring Buffer:: size: " + str(self.pos_ring.size))

		if doEyetrack:
			import pylink
			from EyeLinkCoreGraphicsVE import EyeLinkCoreGraphicsVE

			self.tracker = pylink.EyeLink()
			if self.tracker == None:
				print "Error: Eyelink is not connected"
				sys.exit()

			genv = EyeLinkCoreGraphicsVE(self.screen,self.tracker)
			pylink.openGraphicsEx(genv)

			#Opens the EDF file.
			edfFileName = "TRIAL" + str(trial) + ".EDF";
			self.tracker.openDataFile(edfFileName)

			pylink.flushGetkeyQueue() 


			self.tracker.sendCommand("screen_pixel_coords =	0 0 %d %d" %(VisionEgg.config.VISIONEGG_SCREEN_W,VisionEgg.config.VISIONEGG_SCREEN_H))

			tracker_software_ver = 0
			eyelink_ver = self.tracker.getTrackerVersion()
			if eyelink_ver == 3:
				tvstr = self.tracker.getTrackerVersionString()
				vindex = tvstr.find("EYELINK CL")
				tracker_software_ver = int(float(tvstr[(vindex + len("EYELINK CL")):].strip()))


			if eyelink_ver>=2:
				self.tracker.sendCommand("select_parser_configuration 0")
				if eyelink_ver == 2: #turn off scenelink camera stuff
					self.tracker.sendCommand("scene_camera_gazemap = NO")
			else:
				self.tracker.sendCommand("saccade_velocity_threshold = 35")
				self.tracker.sendCommand("saccade_acceleration_threshold = 9500")

			# set EDF file contents 
			self.tracker.sendCommand("file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON")
			if tracker_software_ver>=4:
				self.tracker.sendCommand("file_sample_data	= LEFT,RIGHT,GAZE,AREA,GAZERES,STATUS,HTARGET")
			else:
				self.tracker.sendCommand("file_sample_data	= LEFT,RIGHT,GAZE,AREA,GAZERES,STATUS")

			# set link data (used for gaze cursor) 
			self.tracker.sendCommand("link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON")
			if tracker_software_ver>=4:
				self.tracker.sendCommand("link_sample_data	= LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,HTARGET")
			else:
				self.tracker.sendCommand("link_sample_data	= LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS")

			if not self.doneSetup:
				self.tracker.doTrackerSetup()
				self.doneSetup = True
			else:
				while 1:
					try:
						error = self.tracker.doDriftCorrect(self.screen.size[0]/2,self.screen.size[1]/2,1,1)
						if error != 27: # ?? from example
							break
						else:
							self.tracker.doTrackerSetup()
					except:
						break


		self.screen.parameters.bgcolor = 106.0/255.0, 147.0/255.0, 0.0
		# Load road data from file and create an image
		roadArray = numpy.loadtxt('road' + str(road) + '.txt')

		# Convert to a Path
		roadPath = ImagePath.Path( map( lambda xy: (xy[0],xy[1]), roadArray.tolist() ) )

		# Use Path to create a plot of the road
		im = Image.new("RGB",(2000,100),(50,50,50))
		draw = ImageDraw.Draw(im)

		# draw each side of the road separately
		draw.line(roadPath[:4000], fill=(200,200,200))
		draw.line(roadPath[4000:], fill=(200,200,200))

		del draw


		# Lay out a road texture in the x-z plane
		roadTexture = Texture(im)

		del im

		eye_height = 2.5

		vertices = [
				(-10,-eye_height,0),
				(-10,-eye_height,-1000),
				(10,-eye_height,0),
				(10,-eye_height,-1000) ]

		rect = TextureStimulus3D(texture=roadTexture,
				lowerleft=vertices[0],
				lowerright=vertices[1],
				upperleft=vertices[2],
				upperright=vertices[3])


		# We will use these later for our camera transforms
		self.camera_matrix = ModelView()
		self.frame_timer = FrameTimer()


		self.outf = open('steersim-' + str(trial) + '-' + str(road) + '-out.txt','wb')

		# Vewport for the road
		viewport3D = Viewport(
			screen=self.screen,
			projection=SimplePerspectiveProjection(fov_x=75.2),
			camera_matrix=self.camera_matrix,
			stimuli=[rect])

		# Construct a sky
		sky_l = 0
		sky_r = self.screen.size[0]
		sky_t = self.screen.size[1]
		sky_b = self.screen.size[1]/2

		sky_vertices = [
			(sky_l,sky_t,0),
			(sky_r,sky_t,0),
			(sky_r,sky_b,0),
			(sky_l,sky_b,0) ]

		sky = Rectangle3D(color=(144.0/255.0,190.0/255.0,1.0),
						  vertex1=sky_vertices[0],
						  vertex2=sky_vertices[1],
						  vertex3=sky_vertices[2],
						  vertex4=sky_vertices[3] )

		wheelTexture = Texture('wheel.png')
		self.wheel = TextureStimulus(texture = wheelTexture,
								internal_format = gl.GL_RGBA,
								position = (self.center, -75),
								anchor = 'center')

		# display the sky in its own viewport
		viewport2D = Viewport(screen=self.screen)
		viewport2D.parameters.stimuli = [sky, self.wheel]

		self.init_state()

		askText = Text(text='Press a key to start',
					   anchor='center',
					   position=(self.center,self.screen.size[1]/2))
		splash = Viewport(screen=self.screen)
		splash.parameters.stimuli = [askText]
		self.askForNext = Presentation(go_duration=(0.5,'seconds'),viewports=[splash])
		self.askForNext.add_controller(None, None, FunctionController(during_go_func=self.wait_for_key))
		self.askForNext.parameters.enter_go_loop = True
		self.askForNext.run_forever()


		self.simPres = Presentation(go_duration=(duration,'seconds'),
						 viewports=[viewport3D,viewport2D],
						 handle_event_callbacks=[(pygame.KEYDOWN,self.check_keypress)])
		self.simPres.add_controller(None, None, FunctionController(during_go_func=self.update))

		if doEyetrack:
			startTime = pylink.currentTime()
			self.tracker.sendMessage("SYNCTIME %d"%(pylink.currentTime()-startTime));
			error = self.tracker.startRecording(1,1,1,1)
			self.tracker.sendMessage("PRES %d START" % (trial))

		self.simPres.go()

		if doEyetrack:
			self.tracker.sendMessage("PRES %d END" % (trial))
			self.tracker.stopRecording()

			# File transfer and cleanup!
			self.tracker.setOfflineMode();
			pylink.msecDelay(500);
			#Close the file and transfer it to Display PC
			self.tracker.closeDataFile()
			self.tracker.receiveDataFile(edfFileName, edfFileName)

		self.outf.close()

		if self.quit:
			raise SystemExit

	def check_keypress(self, event):
		
		if event.key == pygame.K_q:
			self.quit = True
			self.simPres.set(go_duration=(0.0,'seconds'))
		elif event.key == pygame.K_n:
			self.simPres.set(go_duration=(0.0,'seconds'))
		elif event.key == pygame.K_UP:
			self.state.v += 1
		elif event.key == pygame.K_DOWN:
			self.state.v -= 1



