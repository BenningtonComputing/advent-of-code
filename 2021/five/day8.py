#!/usr/bin/env python3
"""
day8-2021.py - my solution to day 8 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/8
               
               use by running `./aoc-day8-2021.py [input]`

               this code was originally posted here:
               https://gist.github.com/fivegrant/2100b3ff610085c533e91cae5a791321
"""

# Snag Data \ stole this from my day 5 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.readlines()
  data = [x.split(" | ") for x in raw_data]
  data = [(x.split(" "), y.strip("\n").split(" ")) for x,y in data]

def alphabetic(string):
  return "".join(sorted(string))

def inverted(mapping):
  return {value: key for key, value in mapping.items()}

def enclosed(x, container):
      for i in x:
        if i not in container:
          return False
      return True

def fix(patterns): # messy, will fix later?
  sizes = [len(x) for x in patterns] 

  # Calculate based off length 
  codes = {"abcdefg":8} # always true
  codes[alphabetic(patterns[sizes.index(2)])] = 1
  codes[alphabetic(patterns[sizes.index(3)])] = 7
  codes[alphabetic(patterns[sizes.index(4)])] = 4

  # Calculate 0, 6, and 9
  candidates = [alphabetic(x) for x in patterns if len(x)==6]

  ## Select 6
  num_6 = [x for x in candidates if not enclosed(inverted(codes)[1], x)][0]
  candidates.remove(num_6)
  codes[num_6] = 6

  ## Select 9
  num_9 = [x for x in candidates if enclosed(inverted(codes)[4], x)][0]
  candidates.remove(num_9)
  codes[num_9] = 9

  ## Select 0
  codes[candidates[0]] = 0
  
  # Calculate 2, 3, and 5
  candidates = [alphabetic(x) for x in patterns if len(x)==5]

  ## Select 3
  num_3 = [x for x in candidates if enclosed(inverted(codes)[1], x)][0]
  candidates.remove(num_3)
  codes[num_3] = 3

  ## Select 5
  num_5 = [x for x in candidates if enclosed(x,inverted(codes)[6])][0]
  candidates.remove(num_5)
  codes[num_5] = 5

  ## Select 2
  codes[candidates[0]] = 2

  return codes

def scan(signals, checklist):
  nums = []
  for signal in signals:
    output_list = []
    valid = fix(signal[0])
    for output in signal[1]:
       identity = alphabetic(output)
       if valid[identity] in checklist:
         output_list += [valid[identity]]
    nums += [output_list]
      
  return nums 

def outputs(signals):
  nums = scan(signals,range(10))
  return [int("".join(map(str,x))) for x in nums]
    
# Part I
print(f'part i: {len(sum(scan(data,[1,4,7,8]),[]))}')

# Part II
print(f'part ii: {sum(outputs(data))}')
