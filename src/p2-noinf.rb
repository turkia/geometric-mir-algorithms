#!/usr/bin/env ruby
# Prototype of algoritm P2 for simulation and learning.
# End of source NOT marked with [inf,inf], unlike in the article pseudocode.
# Copyright Mika Turkia
# May 15th, 2003

# dscale
#s = [[0,62], [24,64], [48,66], [72, 67], [96,69],[120,71],[144,73],[168,74]]
#p = [[0,62], [24,64]]

# polytest
s = [[0,65], [0,69], [0,72], [200,64], [200,67], [200,72], [400,62],[400,65],[600,60],[600,64],[600,72]]
p = [[0,72], [200,72], [400,62], [600,72]]

# minus infinity
f = [-99999, -99999]
c = 0

# array used as a priority queue
# priority queue items: [i, f[i]]
# i.e. index to pattern and difference vector
pq = []

# array containing indexes to source
q = []

# all indexes refer to first point in the source
p.size.times do q.push(0) end

# push difference vectors between first source note and all pattern notes to priority queue
p.size.times do |i| pq.push([i, [s[0][0] - p[i][0], s[0][1] - p[i][1]]]) end


(p.size * s.size).times do

	# sort the array used as priority queue
	pq.sort! do |a,b| a[1] <=> b[1] end

	# get minimum element
	temp = pq.shift

	# pattern index of the difference vector
	ii = temp[0]

	# difference vector
	fn = temp[1]

	# move to next note in the source
	q[ii] += 1

	# update the difference vector of this pattern index
	# note: we must check the end of source
	pq.push([ ii, [s[q[ii]][0] - p[ii][0], s[q[ii]][1] - p[ii][1]] ]) if q[ii] < s.size

	if fn == f then c += 1
	else 
		# if c may be 1, also f=-infinity matches
		if c >= 2 then puts "match: f=(#{f[0]},#{f[1]}) c=#{c}" end
		f = fn
		c = 1
	end
end


