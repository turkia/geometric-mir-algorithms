#!/usr/bin/env ruby

# we use a priority queue implementation from https://github.com/kanwei/algorithms
require 'algorithms'


class MIR 

	# Prototype of algoritm P2. End of source NOT marked with [inf,inf], unlike in the article pseudocode.
	# Copyright Mika Turkia, May 15th, 2003 and September 9th, 2012. 
	def self.p2(s, p)

		# minus infinity
		f = [-99999, -99999]
		c = 0
		matches = []

		# priority queue items are of form [i, f[i]],
		# where i is an index to pattern, and f[i] is a difference vector. 
		# priority queue returns the item with the smallest difference vector first.
		pq = Containers::PriorityQueue.new { |a, b| (a <=> b) == -1 }

		# array containing indexes to source. 
		# initially, all indexes refer to first point in the source.
		q = Array.new(p.size) { 0 }

		# push difference vectors between first source note and all pattern notes to priority queue.
		p.size.times do |i| 
			vec = [s[0][0] - p[i][0], s[0][1] - p[i][1]]
			pq.push([i, vec], vec)
		end

		(p.size * s.size).times do

			# get the smallest difference vector.
			# ii = pattern index of the difference vector
			# fn = difference vector
			ii, fn = pq.pop

			# move to next note in the source.
			q[ii] += 1

			# update the difference vector of this pattern index.
			# note: we must check the end of source.
			if q[ii] < s.size then
				vec = [s[q[ii]][0] - p[ii][0], s[q[ii]][1] - p[ii][1]]
				pq.push([ii, vec], vec) 
			end

			if fn == f then c += 1
			else 
				# if c may be 1, also f=-infinity matches
				matches << {:f => f, :c => c} if c >= 2 
				f = fn
				c = 1
			end
		end
		matches
	end
end


# testing 

source  = [[0,65], [0,69], [0,72], [200,64], [200,67], [200,72], [400,62],[400,65],[600,60],[600,64],[600,72]]
pattern = [[0,72], [200,72], [400,62], [600,72]]

puts MIR::p2(source, pattern)

