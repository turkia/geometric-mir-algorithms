#!/usr/bin/env ruby

# We use a priority queue implementation from https://github.com/kanwei/algorithms. 
require 'algorithms'

# Pure Ruby implementations of advanced algorithms for musical information retrieval (MIR), i.e. melody searching. 
# Implementations follow pseudocode in the respective articles and were used in prototyping the C implementations.
# Therefore their style differs from idiomatic Ruby. 
#
# Copyright Mika Turkia 2002-2003.
class MIR

	# Prototype of algorithm P1. End of source marked with [inf,inf] like in the article pseudocode.
	# Copyright Mika Turkia, May 15th, 2003.
	def self.p1(t, p)

		f = [-99999, -99999]
		c = 0
		matches = []

		# priority queue simulated with an array.
		q = []
		p.size.times do q.push([-99999,-99999]) end
		q.push([99999,99999])

		for ti in 0..t.size - p.size - 1 do

			f[0] = t[ti][0] - p[0][0]
			f[1] = t[ti][1] - p[0][1]
			pi = 0

			loop do
				# start comparing from the second note of the pattern
				pi += 1
				break if pi==p.size

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


	# Prototype of algorithm P2. Unlike in the article pseudocode, the end of source is not marked with [inf,inf]. 
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


	# Prototype of ShiftOrAnd algorithm. No transposition invariance, exact matches only.
	# Copyright Mika Turkia 2002/2012.
	def self.shiftorand(chords, pattern)

		matches = []
		m = nil
		t = []
		mask = e = 2 ** pattern.size - 1
		tmppre = 2 ** 32 - 1

		for i in 0..127 do t[i] = mask end

		for i in 0...pattern.size do t[pattern[i]] -= 2 ** i end

		for j in 0...chords.size do

			tmp = tmppre
			chords[j].each do |note| tmp &= t[note] end
			e = ((e << 1) | tmp) & mask

			matches << {:start => j - pattern.size + 1, :end => j} if (e[pattern.size - 1] == 0)
		end
		matches
	end
end
