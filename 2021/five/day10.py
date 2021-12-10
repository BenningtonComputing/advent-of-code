#!/usr/bin/env python3
"""
day10-2021.py - my solution to day 10 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/10
               
               use by running `./aoc-day10-2021.py [input]`

               this code was originally posted here:
               https://gist.github.com/fivegrant/8e451be44b89ddcfe63e46532bf18821

"""

# Snag Data \ stole this from my day 9 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.readlines()
  data = [x.strip("\n") for x in raw_data]

def inverted(mapping):
  return {value: key for key, value in mapping.items()}

pairs = {
  "{": "}",
  "[": "]",
  "(": ")",
  "<": ">"
}

point_values = {
  "}": 1197,
  "]": 57,
  ")": 3,
  ">": 25137
}

auto_values = {
  "{": 3,
  "[": 2,
  "(": 1,
  "<": 4
}

class Stack:
  def __init__(self, string):
    self.pile = ""
    self.string = string
    self.position = 0
  
  def step(self):
    if self.position >= len(self.string): return -1
    current = self.string[self.position]
    if current in pairs:
      self.pile += current
      self.position += 1
      return 0
    elif pairs[self.pile[-1]] == current:
      self.pile = self.pile[:-1]
      self.position += 1
      return 0
    else: # ERROR!
      return point_values[current]
    
  def autocomplete(self):
    points = 0
    while points == 0:
      points = self.step()
    points = 0
    for s in reversed(self.pile):
      points *= 5
      points += auto_values[s]
    return points
      
def score(line):
  stack = Stack(line)
  points = 0
  while points == 0:
    points = stack.step()
  return points if points != -1 else 0

corrupted = [score(x) for x in data]
incomplete = [data[i] for i in range(len(corrupted)) if corrupted[i] == 0]

# Part I
print(f'part i: {sum(corrupted)}')

# Part II
completed = sorted([Stack(x).autocomplete() for x in incomplete])
print(f'part ii: {completed[len(completed)//2]}')
