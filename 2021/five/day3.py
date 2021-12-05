#!/usr/bin/env python3
"""
day3-2021.py - my solution to day 3 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/3


               this code was originally posted here:
               https://gist.github.com/fivegrant/e4cc6499f5863d254c4c0f3c8e450599
"""

from math import ceil

# Snag Data \ stole this from my day 2 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.read().splitlines()
  raw_data = raw_data[:-1] if len(raw_data[-1]) == 0 else raw_data
  data = [int(x,base=2) for x in raw_data]

# Part I
def common_bit(reading, i, most_common = True):
  bit = 1 << i
  amount = sum(map(lambda x: (x & bit) >> i, reading))
  if(most_common): 
    return 1 if amount >= len(reading)/2 else 0
  else:
    return 1 if amount < len(reading)/2 else 0

def power_consumption(reading):
  bit_count = len(bin(max(reading))[2:])
  gamma = 0
  epsilon = 0
  for i in range(bit_count):
    if common_bit(reading, i) == 1: 
      gamma += 1 << i 
    else:
      epsilon += 1 << i
  return gamma * epsilon 
  

print(f'part i: {power_consumption(data)}')

# Part II

def pick(reading, most_common = True):
  index = len(bin(max(reading))[2:])
  candidates = [(index - len(x))*"0" + x
     for x in [bin(n)[2:] for n in reading.copy()]]
  while(len(candidates) > 1):
    criteria = common_bit([int(x,base=2) for x in candidates], 
                           index - 1, most_common)
    check = lambda x: criteria == int(x[-index])
    candidates = list(filter(check, candidates))
    index -= 1
  return int(candidates[0],base=2)
  
def life_support(reading):
  oxygen = pick(reading)
  dioxide = pick(reading, False)
  return oxygen * dioxide
print(f'part ii: {life_support(data)}')
