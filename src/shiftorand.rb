#!/usr/bin/env ruby

# Copyright Mika Turkia 2002/2012
class MIR

	# Prototype of ShiftOrAnd algorithm. 
	# No transposition invariance, exact matches only.
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


# testing 

chords = [[60, 62, 64], [64, 66], [62, 68], [66, 68]]
pattern = [62, 66]

puts MIR::shiftorand(chords, pattern)

