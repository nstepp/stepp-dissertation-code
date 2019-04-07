import numpy

class RingBuffer:

	def __init__(self, init, size):
		self.size = size
		self.buffer = numpy.repeat(init, size)
		self.caret = -1
	

	def add(self, val):
		'''Add a value to the next spot on th ring, overwriting the oldest value.'''
		self.caret = (self.caret + 1) % self.size
		self.buffer[self.caret] = val
	
	def head(self):
		'''Return the "head" of the list, being the oldest value on the ring.'''
		return self.buffer[ (self.caret+1) % self.size ]
	
	def tail(self):
		'''Return the "tail" of the list, being the newest value on the ring.'''
		return self.buffer[self.caret]


