#!/usr/bin/env python3
"""
day6-2021.py - my solution to day 6 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/6

               this code was originally posted here:
               https://gist.github.com/fivegrant/41a2a0efff353d50da66af2a64b3bac0
"""

from collections import defaultdict

# Snag Data \ stole this from my day 5 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.read()
  data = [int(x) for x in raw_data.split(',')]

class Population:
  def __init__(self, initial):
    self.fish = defaultdict(lambda: 0)
    for num in initial:
      self.fish[num] += 1
  
  def advance(self):
    incoming = defaultdict(lambda: 0)
    for i in reversed(range(9)):
      if i == 0:
        incoming[8] = self.fish[0]
        incoming[6] += self.fish[0]
      else:
        incoming[i - 1] = self.fish[i]
    self.fish = incoming

  def days(self, n):
    for i in range(n):
      self.advance()
    return sum(list(self.fish.values()))


# Part I
part1 = Population(data)
print(f'part i: {part1.days(80)}')

# Part II
part2 = Population(data)
print(f'part ii: {part2.days(256)}')
