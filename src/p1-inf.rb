#!/usr/bin/env ruby

# Prototype of algoritm P1 for simulation and learning.
# End of source marked with [inf,inf] like in the article pseudocode.
# Copyright Mika Turkia
# May 15th, 2003

# dscale
#t = [[0,62], [24,64], [48,66], [72, 67], [96,69],[120,71],[144,73],[168,74],[99999,99999]]
#p = [[0,62], [24,64]]

# polytest
t = [[0,65], [0,69], [0,72], [200,64], [200,67], [200,72], [400,62],[400,65],[600,60],[600,64],[600,72],[99999,99999]]
p = [[0,72], [200,72], [400,62], [600,72]]

f = [-99999, -99999]
c = 0

# priority queue simulated with an array.
q = []
p.size.times do q.push([-99999,-99999]) end
q.push([99999,99999])

for ti in 0..t.size - p.size-1 do

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

	if pi == p.size then puts "match: (#{f[0]},#{f[1]})" end
end


