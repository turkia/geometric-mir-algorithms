#!/usr/bin/env ruby

# Prototype of ShiftOrAnd algorithm
# No transposition invariance, exact matches only.
# Copyright Mika Turkia 2002

chords = [[60, 62, 64], [64, 66]]
pattern = [62, 66]

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
	if (e[pattern.size - 1] == 0) then
		puts "Match: " + (j-pattern.size+1).to_s + "-" + j.to_s
	end
end

