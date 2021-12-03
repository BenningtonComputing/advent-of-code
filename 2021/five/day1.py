#!/usr/bin/env python3
"""
day1-2021.py - my solution to day 1 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/1

               this code was originally posted here:
               https://gist.github.com/fivegrant/763bb178f918d00b8d5602dbddddf850
"""

# Snag Data
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.read().splitlines()
  raw_data = raw_data[:-1] if len(raw_data[-1]) == 0 else raw_data
  data = list(map(int,raw_data))

# Part 1
def increases(nums):
  count = 0
  for i in range(1, len(nums)):
    count += 1 if nums[i] > nums[i - 1] else 0  
  return count
print(f'part i answer: {increases(data)}')

# Part 2
revised_data = list(map(lambda i: data[i-1]+data[i]+data[i+1], range(1, len(data) - 1)))
print(f'part ii answer: {increases(revised_data)}')
