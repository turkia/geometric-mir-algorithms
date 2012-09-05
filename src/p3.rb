#!/usr/bin/env ruby

# Simple prototype implementation of algorithm P3
# Mika Turkia 2003

# dscale
t = [[0,62,24], [24,64,24], [48,66,24], [72, 67,24], [96,69,24],[120,71,24],[144,73,24],[168,74,24]]
p = [[0,62,24], [24,64,24]]

# polytest
t = [[0,65,200], [0,69,200], [0,72,200], [200,64,200], [200,67,200], [200,72,200], [400,62,200],[400,65,200],[600,60,200],[600,64,200],[600,72,200]]
p = [[0,65,200], [0,69,200], [0,72,200], [200,64,200], [200,67,200], [200,72,200], [400,62,200],[400,65,200],[600,60,200],[600,64,200],[600,72,200]]
#p = [[0,69,200], [200,67,200], [400,65,200]]
#p = [[0,64,200], [200,62,200], [400,72,200]]

# simple
#t = [[0,1,1],[1,0,1],[2,1,1]]
#p = [[0,1,1],[1,0,1],[2,1,1]]

# overhead film example
#t = [[0,1,1], [1,0,1]]
#p = [[0,1,1], [1,0,2]]

# simplest
#t = [[1,2,1],[2,3,1],[3,1,1]]
#p = [[1,1,1],[2,2,1],[3,0,1]]


class Point
	attr_reader :x, :y, :z
	def initialize(x, y, z)
		@x = x
		@y = y
		@z = z
	end
	def to_s
		"(#{@x},#{@y},#{@z})"
	end
end

pattern = []
p.each do |pi| pattern.push(Point.new(pi[0],pi[1],pi[2])) end

text = []
t.each do |ti| text.push(Point.new(ti[0],ti[1],ti[2])) end

class VerticalTranslationTableItem
	attr_reader :y
	attr_accessor :value, :slope, :prev_x, :notes, :overlapcounter
	def initialize(y, value, slope)
		@y = y
		@value = value
		@slope = slope
		@prev_x = 0
		@notes = []
		@overlapcounter = []
	end

	def <=>(b)
		@y <=> b.y
	end
end

class VerticalTranslationTable
	attr_accessor :items
	def initialize
		@items = []
		256.times do |i|
			items[i] = VerticalTranslationTableItem.new(i, 0, 0)
		end
	end
end

class TurningPoint < Point
	attr_reader :textindex
	def initialize(x, y, textindex, type)
		@x = x 
		@y = y
		# z could be undefined?
		@textindex = textindex
	end
	def to_s
		" f=(#{@x},#{y}) textindex=#{@textindex}"
	end
	def <=>(b)
		if @x != b.x then @x <=> b.x else @y <=> b.y end
	end
end

class TurningPointPointer
	attr_accessor :pattern_startpoint, :pattern_endpoint
	def initialize(startp, endp)
		@pattern_startpoint = startp
		@pattern_endpoint = endp
	end
end

# priority queue simulated with an array
class PriorityQueue
	def initialize()
		@points = []
	end
	def add(turningpoint)
		@points.push(turningpoint)
		@points.sort! do |a,b| a.x <=> b.x end		# sort by x only
	end
	def get_min
		@points.shift
	end
	def size
		@points.size
	end
end

class TranslationVector
	attr_reader :tpindex, :x, :y, :textindex, :patternindex, :text_is_start, :pattern_is_start
	def initialize(tp_array_index, x, y, textindex, patternindex, texttype, patterntype)
		@tpindex = tp_array_index
		@x = x
		@y = y
		@textindex = textindex
		@patternindex = patternindex
		@text_is_start = texttype
		@pattern_is_start = patterntype
	end
	def <=>(b)
		if @x != b.x then @x <=> b.x else @type <=> b.type end
		#if @x != b.x then @x <=> b.x elsif not @y == b.y then @y <=> b.y else @type <=> b.type end
		#@x <=> b.x
	end
	def to_s
		"tpind=#{@tpindex} f=(#{@x},#{@y}) tind=#{@textindex} pind=#{@patternindex} text_is_start=#{@text_is_start} pattern_is_start=#{@pattern_is_start}"
	end
end


endpoints = []
startpoints = []
turningpointpointers = []
verticaltranslationtable = VerticalTranslationTable.new
pq = PriorityQueue.new


# create turning points; start and end points must be traversed separately.
text.each_with_index do |ti, i|
	startpoints.push(TurningPoint.new(ti.x, ti.y, i, true))
	endpoints.push(TurningPoint.new(ti.x + ti.z, ti.y, i, false))
end
endpoints.sort!

# create an array whose items have two pointers each; each item points to turning point array item
# first part of main algorithm: populate priority queue with initial items
# (loops merged)
pattern.each_with_index do |pi, i|

	turningpointpointers[i] = TurningPointPointer.new(startpoints[0], endpoints[0])

	textindex = turningpointpointers[0].pattern_startpoint.textindex
	verticalshift =  turningpointpointers[0].pattern_startpoint.y - pi.y
	pq.add(TranslationVector.new(0, turningpointpointers[0].pattern_startpoint.x - (pi.x + pi.z), verticalshift, textindex, i, true, false))
	pq.add(TranslationVector.new(0, turningpointpointers[0].pattern_startpoint.x - pi.x,          verticalshift, textindex, i, true, true))

	textindex = turningpointpointers[0].pattern_endpoint.textindex
	verticalshift =  turningpointpointers[0].pattern_endpoint.y - pi.y
	pq.add(TranslationVector.new(0, turningpointpointers[0].pattern_endpoint.x - (pi.x + pi.z), verticalshift, textindex, i, false, false))
	pq.add(TranslationVector.new(0, turningpointpointers[0].pattern_endpoint.x - pi.x, verticalshift, textindex, i, false, true))
end


# prev_x should be x on the first loop but since slope is zero it doesn't matter
best = 0
notes = nil

# create translation vectors
(pattern.size * text.size * 4).times do |loopind|

	# get minimum element
	min = pq.get_min

	# attempt to record matched notes: does not work if there is a note with same vertical translation in the pattern. 
	# no better solution known at the moment.
        if min.text_is_start and not min.pattern_is_start then verticaltranslationtable.items[min.y].notes[min.patternindex] = min.textindex end
 
	# update longest common time for this vertical translation
	verticaltranslationtable.items[min.y].value += verticaltranslationtable.items[min.y].slope * \
		(min.x - verticaltranslationtable.items[min.y].prev_x)
	verticaltranslationtable.items[min.y].prev_x = min.x

	# adjust slope
	if not min.text_is_start == min.pattern_is_start
		verticaltranslationtable.items[min.y].slope += 1 
	else 
		verticaltranslationtable.items[min.y].slope -= 1 
	end

	# check for best match
	if verticaltranslationtable.items[min.y].value > best
		best = verticaltranslationtable.items[min.y].value
		notes = verticaltranslationtable.items[min.y].notes
	end

	# move pointer; insert new translation vector; must know if patternpoint is start or end, and the same for text
	if (min.tpindex + 1 < text.size)
	if min.text_is_start

		turningpointpointers[min.patternindex].pattern_startpoint = startpoints[min.tpindex + 1]
		verticalshift = turningpointpointers[min.patternindex].pattern_startpoint.y - pattern[min.patternindex].y
		textindex = turningpointpointers[min.patternindex].pattern_startpoint.textindex

		if min.pattern_is_start
			pq.add(TranslationVector.new(min.tpindex+1, turningpointpointers[min.patternindex].pattern_startpoint.x - \
				pattern[min.patternindex].x, verticalshift, textindex, min.patternindex, true, true))
		else
			pq.add(TranslationVector.new(min.tpindex+1, turningpointpointers[min.patternindex].pattern_startpoint.x - \
				(pattern[min.patternindex].x + pattern[min.patternindex].z), verticalshift, textindex, min.patternindex, true, false))
		end
	else

		turningpointpointers[min.patternindex].pattern_endpoint = endpoints[min.tpindex + 1]
		verticalshift = turningpointpointers[min.patternindex].pattern_endpoint.y - pattern[min.patternindex].y
		textindex = turningpointpointers[min.patternindex].pattern_endpoint.textindex

		if min.pattern_is_start
			pq.add(TranslationVector.new(min.tpindex + 1, turningpointpointers[min.patternindex].pattern_endpoint.x - \
				pattern[min.patternindex].x, verticalshift, textindex, min.patternindex, false, true))
		else
			pq.add(TranslationVector.new(min.tpindex + 1, turningpointpointers[min.patternindex].pattern_endpoint.x - \
				(pattern[min.patternindex].x + pattern[min.patternindex].z), verticalshift, textindex, min.patternindex, false, false))
		end
	end
	end
end


print "\nlongest common duration=#{best}\nmatched notes: "
notes.each do |n| print "(#{t[n].join(",")}) " end if not notes.nil?
puts


