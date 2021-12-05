#!/usr/bin/env python3
"""
day5-2021.py - my solution to day 5 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/5


               this code was originally posted here:
               https://gist.github.com/fivegrant/769bb0671e99b0ac0902482922f339a3
"""

from collections import defaultdict

# Snag Data \ stole this from my day 4 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.readlines()
  data = [list(map(int,x.split(",") + y.split(","))) 
          for x,y in [x.split(" -> ") for x in raw_data]]


class Line:
  def __init__(self, start, end):
    self.start = start
    self.end = end
    self.vert = start[0] == end[0]
    self.slope = 0 if self.is_flat() else \
                 1 if start[1] < end[1] else -1
    self.direction = (1 if start[0] < end[0] else -1) if not self.vert else \
                      1 if start[1] < end[1] else -1
    
  def is_flat(self):
    return self.vert or self.start[1] == self.end[1]
  
  def __str__(self):
    return f'{self.start} -> {self.end} (slope:{self.slope})\n'

  def calc_points(self):
    points = []
    current = self.start
    while current != self.end:
      points += [current]
      if not self.vert:
        current = (current[0] + self.direction*1, current[1] + self.slope)
      else:
        current = (current[0], current[1] + self.direction*1)
    return points + [self.end]

class Grid: # Reused some code from my Day 4 Board Class
  def __init__(self, data): 
    self.dim = max(sum(data,start=[])) + 1
    self.lines = [Line((x[0],x[1]),(x[2],x[3])) for x in data]

  def intersections(self,point_sig = 2, vertOnly = False):
    body = defaultdict(lambda: 0)
    lines = [x for x in self.lines if x.is_flat()] if vertOnly else self.lines
    for l in lines:
      points = l.calc_points()
      for point in points:
        body[point] += 1
    return sum(map(lambda x: x >= 2, body.values()))

grid = Grid(data)
# Part I
print(f'part i: {grid.intersections(vertOnly=True)}')

# Part II
print(f'part ii: {grid.intersections()}')
