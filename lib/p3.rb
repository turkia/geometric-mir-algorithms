#!/usr/bin/env ruby

require 'algorithms'

class MIR 

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

	# For p3.
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

	# For p3.
	class VerticalTranslationTable
		attr_accessor :items
		def initialize
			@items = []
			256.times do |i|
				items[i] = VerticalTranslationTableItem.new(i, 0, 0)
			end
		end
	end

	# For p3b.
	class VerticalTranslationTableItem2
		attr_reader :y
		attr_accessor :value, :slope, :prev_x, :notes, :overlapcounter14, :overlapcounter2, :overlapcounter13
		def initialize(y, value, slope, pattern_size)
			@y = y
			@value = value
			@slope = slope
			@prev_x = 0
			@notes = []
			@overlapcounter13 = []
			@overlapcounter14 = []
			@overlapcounter2 = []
			pattern_size.times do |i|
				@overlapcounter14[i] = 0
				@overlapcounter13[i] = 0
				@overlapcounter2[i] = false
			end
		end

		def <=>(b)
			@y <=> b.y
		end
	end

	# For p3b.
	class VerticalTranslationTable2
		attr_accessor :items
		def initialize(pattern_size)
			@items = []
			256.times do |i|
				items[i] = VerticalTranslationTableItem2.new(i, 0, 0, pattern_size)
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
		end
		def to_s
			"tpind=#{@tpindex} f=(#{@x},#{@y}) tind=#{@textindex} pind=#{@patternindex} text_is_start=#{@text_is_start} pattern_is_start=#{@pattern_is_start}"
		end
	end

	class Containers::PriorityQueue
		# A method for adding points that sorts the priority queue by x only.
		def add(point)	
			push(point, point.x)
		end
	end

	# Algorithm P3.
	# Mika Turkia 2003.
	def self.p3(t, p)

		pattern = []
		p.each do |pi| pattern.push(Point.new(pi[0],pi[1],pi[2])) end

		text = []
		t.each do |ti| text.push(Point.new(ti[0],ti[1],ti[2])) end

		endpoints = []
		startpoints = []
		turningpointpointers = []
		verticaltranslationtable = VerticalTranslationTable.new

		# Pop smallest items first, i.e. reverse the default order. 
		pq = Containers::PriorityQueue.new { |x, y| (x <=> y) == -1 }

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
			min = pq.pop

			# attempt to record matched notes: does not work if there is a note with same vertical translation in the pattern. 
			# no better solution known at the moment.
		        if min.text_is_start and not min.pattern_is_start then verticaltranslationtable.items[min.y].notes[min.patternindex] = min.textindex end
 
			# update longest common time for this vertical translation
			verticaltranslationtable.items[min.y].value += verticaltranslationtable.items[min.y].slope * 
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
		{ :longest_common_duration => best, :matched_notes => (notes.map { |n| t[n] } if notes) }
	end

	# A prototype of algorithm P3, which ignores overlapping note segments by using counters.
	# Mika Turkia and Veli Makinen 2003.
	def self.p3b(t, p)

		pattern = []
		p.each do |pi| pattern.push(Point.new(pi[0],pi[1],pi[2])) end

		text = []
		t.each do |ti| text.push(Point.new(ti[0],ti[1],ti[2])) end

		endpoints = []
		startpoints = []
		turningpointpointers = []
		verticaltranslationtable = VerticalTranslationTable2.new(p.size)

                # Pop smallest items first, i.e. reverse the default order. 
                pq = Containers::PriorityQueue.new { |x, y| (x <=> y) == -1 }

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
			min = pq.pop

			# update longest common time for this vertical translation
			verticaltranslationtable.items[min.y].value += verticaltranslationtable.items[min.y].slope * \
				(min.x - verticaltranslationtable.items[min.y].prev_x)
			verticaltranslationtable.items[min.y].prev_x = min.x

			if min.text_is_start 
				if min.pattern_is_start
					# type 2
					if verticaltranslationtable.items[min.y].overlapcounter2[min.patternindex] == false
						verticaltranslationtable.items[min.y].slope -= 1 
						verticaltranslationtable.items[min.y].overlapcounter2[min.patternindex] = true
					end
				else
					# type 1
					if verticaltranslationtable.items[min.y].overlapcounter14[min.patternindex] == 0
						verticaltranslationtable.items[min.y].slope += 1 
					end
					verticaltranslationtable.items[min.y].overlapcounter14[min.patternindex] += 1
					verticaltranslationtable.items[min.y].overlapcounter13[min.patternindex] += 1
				end
			else
				if min.pattern_is_start
					# type 4
					verticaltranslationtable.items[min.y].overlapcounter14[min.patternindex] -= 1
					if verticaltranslationtable.items[min.y].overlapcounter14[min.patternindex] == 0
						verticaltranslationtable.items[min.y].slope += 1 
						verticaltranslationtable.items[min.y].overlapcounter2[min.patternindex] = false
					end
				else
					# type 3
					verticaltranslationtable.items[min.y].overlapcounter13[min.patternindex] -= 1
					if verticaltranslationtable.items[min.y].overlapcounter13[min.patternindex] == 0
						verticaltranslationtable.items[min.y].slope -= 1 
					end
				end
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
		{ :longest_common_duration => best }
	end
end
