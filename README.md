geometric-mir-algorithms
========================

Prototype implementations of advanced CBMR/MIR algorithms in Ruby, produced in 2002-2003 as a part of a musical information retrieval research project C-BRAHMS at the University of Helsinki, Department of Computer Science.

Algorithms P1, P2 and P3 are described in the following publication: 

Ukkonen, Esko; Lemström, Kjell; Mäkinen, Veli:
Geometric algorithms for transposition invariant content-based music retrieval. 
in Proc. 4th International Conference on Music Information Retrieval, pp. 193-199, 2003.

Full text is online at https://tuhat.halvi.helsinki.fi/portal/services/downloadRegister/14287445/03ISMIR_ULM.pdf

Implementations follow pseudocode in the respective articles and were used in prototyping the C implementations.
Therefore their style differs from idiomatic Ruby. 

Usage
-----

Algorithms P1 and P2 expect source and pattern to be an array containing points, whose first element contains the time and the second the pitch. 
By convention pitches are MIDI values. 

```ruby
source = [[0,65], [0,69], [0,72], [200,64], [200,67], [200,72], [400,62],[400,65],[600,60],[600,64],[600,72]]
pattern = [[0,72], [200,72], [400,62], [600,72]]
puts MIR::p1(source,pattern).inspect
```

```ruby
source = [[0,65], [0,69], [0,72], [200,64], [200,67], [200,72], [400,62],[400,65],[600,60],[600,64],[600,72]]
pattern = [[0,72], [200,72], [400,62], [600,72]]

puts MIR::p2(source, pattern)
```

Algorithm P3 expects the source as an array containing points, whose first element is start time, second element is pitch, and third is duration. 

```ruby
source = [[0,65,200], [0,69,200], [0,72,200], [200,64,200], [200,67,200], [200,72,200], [400,62,200],[400,65,200],[600,60,200],[600,64,200],[600,72,200]]
pattern = [[0,65,200], [0,69,200], [0,72,200], [200,64,200], [200,67,200], [200,72,200], [400,62,200],[400,65,200],[600,60,200],[600,64,200],[600,72,200]]
puts MIR::p3(source, pattern)
```

Results are described in the article. 

ShiftOrAnd algorithm expects source as chords, i.e. an array containing arrays, each of which represents a chord, i.e. the notes playing simultaneously. 
The pattern is one-dimensional, i.e. only one note may match notes in one chord. There is no timing information. 

```ruby
chords = [[60, 62, 64], [64, 66], [62, 68], [66, 68]]
pattern = [62, 66]

puts MIR::shiftorand(chords, pattern)
```


More information at http://www.cs.helsinki.fi/u/turkia/music/. 

Copyright Mika Turkia 2002-2012.
License: GNU AGPLv3. 
