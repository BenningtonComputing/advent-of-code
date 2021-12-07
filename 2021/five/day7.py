#!/usr/bin/env python3
"""
day7-2021.py - my solution to day 7 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/7
               
               use by running `./aoc-day7-2021.py [input]`

               this code was originally posted here:
               https://gist.github.com/fivegrant/45a81e7975deef37328cf8600dae5636
"""

from collections import defaultdict

# Snag Data \ stole this from my day 5 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.read()
  data = [int(x) for x in raw_data.split(',')]

def cost(nums, fun):
  """ originally used:
      `return [sum(map(fun(num), nums), start=0) for num in range(max(nums)+1)]`
      but now we have a slight speed up.
  """
  current = float('inf')
  for num in range(max(nums)+1):
    result = sum(map(fun(num), nums), start=0)
    if result > current:
      break
    else:
      current = result
  return current

# Part I
def sub(num):
  return lambda x: abs(x-num)

print(f'part i: {cost(data,sub)}')

# Part II
def series(i):
  return sum(range(1,i+1))

def grow(num):
  dist = sub(num)
  return lambda x: series(dist(x))

print(f'part ii: {cost(data,grow)}')
