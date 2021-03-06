#!/usr/bin/env ruby

# We use a priority queue implementation from https://github.com/kanwei/algorithms. 
require 'algorithms'

# Pure Ruby implementations of advanced algorithms for musical information retrieval (MIR), i.e. melody searching. 
# 
# Algorithms P1, P2 and P3 are described in the following publication: 
#
# Ukkonen, Esko; Lemström, Kjell; Mäkinen, Veli:
# Geometric algorithms for transposition invariant content-based music retrieval. 
# in Proc. 4th International Conference on Music Information Retrieval, pp. 193-199, 2003.
# https://tuhat.halvi.helsinki.fi/portal/services/downloadRegister/14287445/03ISMIR_ULM.pdf
# 
# Implementations follow the pseudocode in the article and were used in prototyping the C implementations.
# Therefore their style differs somewhat from idiomatic Ruby. 
#
# Copyright Mika Turkia 2002-2012.
class MIR

	INFINITY_POINT = [Float::INFINITY, Float::INFINITY]
	MINUS_INFINITY_POINT = INFINITY_POINT.map { |i| -i }


	# Algorithm P1 version 1. 
	# Following the article pseudocode the end of source is marked with [inf,inf]. 
	# Copyright Mika Turkia, May 15th, 2003 and and September 6th, 2012.
	def self.p1(source, p)

		t = source.push(INFINITY_POINT)

		f = MINUS_INFINITY_POINT
		c = 0
		matches = []

		# priority queue simulated with an array.
		q = Array.new(p.size) { MINUS_INFINITY_POINT }
		q.push(INFINITY_POINT)

		for ti in 0..t.size - p.size - 1 do

			f[0] = t[ti][0] - p[0][0]
			f[1] = t[ti][1] - p[0][1]
			pi = 0

			loop do
				# start comparing from the second note of the pattern
				pi += 1
				break if pi == p.size

				# temporary index for traversing t
				tti = ti + pi

				# q[pi] = max(q[pi], t[ti])
				q[pi] = t[tti] if q[pi][0] < t[tti][0] or (q[pi][0] == t[tti][0] and q[pi][1] < t[tti][1])

				# move q[pi] pointer (corresponding to p[pi]) on in the source until a match cannot be found
				while ((q[pi][0] < p[pi][0] + f[0]) or ((q[pi][0] == p[pi][0] + f[0]) and (q[pi][1] < p[pi][1] + f[1]))) do 
					tti += 1
					q[pi] = t[tti]
				end

				break if (q[pi][0] > p[pi][0] + f[0]) or ((q[pi][0] == p[pi][0] + f[0]) and (q[pi][1] > p[pi][1] + f[1]))
			end

			if pi == p.size then matches << [f[0], f[1]] end
		end
		matches
	end


	# Algorithm P1 version 2. 
	# Unlike in the article pseudocode the end of source is not marked with [inf,inf]. 
	# Copyright Mika Turkia, May 15th, 2003 and and September 6th, 2012.
	def self.p1b(t, p)

		f = MINUS_INFINITY_POINT
		c = 0
		matches = []

		# priority queue simulated with an array.
		q = Array.new(p.size) { MINUS_INFINITY_POINT }
		q.push(INFINITY_POINT)
		match = true

		for ti in 0..t.size - p.size do

			f[0] = t[ti][0] - p[0][0]
			f[1] = t[ti][1] - p[0][1]
			pi = 0
			match = true

			loop do
				# start comparing from the second note of the pattern
				pi += 1
				break if pi == p.size

				# temporary index for traversing t
				tti = ti + pi

				# q[pi] = max(q[pi], t[ti])
				q[pi] = t[tti] if q[pi][0] < t[tti][0] or (q[pi][0] == t[tti][0] and q[pi][1] < t[tti][1])

				# move q[pi] pointer (corresponding to p[pi]) on in the source until a match cannot be found
				while ((q[pi][0] < p[pi][0] + f[0]) or ((q[pi][0] == p[pi][0] + f[0]) and (q[pi][1] < p[pi][1] + f[1]))) do 
					tti += 1
					if tti == t.size then match=false; break end
					q[pi] = t[tti]
				end

				break if (q[pi][0] > p[pi][0] + f[0]) or ((q[pi][0] == p[pi][0] + f[0]) and (q[pi][1] > p[pi][1] + f[1]))
			end

			if pi == p.size and match then matches << [f[0], f[1]] end
		end
		matches
	end


	# Algorithm P2. 
	# Copyright Mika Turkia, May 15th, 2003 and September 5th, 2012. 
	def self.p2(s, p)

		# Unlike in the article pseudocode, the end of source is not marked with [inf,inf]. 
		f = MINUS_INFINITY_POINT
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

require_relative 'p3'
