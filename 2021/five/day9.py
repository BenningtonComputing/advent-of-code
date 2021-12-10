#!/usr/bin/env python3
"""
day9-2021.py - my solution to day 9 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/9
               
               use by running `./aoc-day9-2021.py [input]`

               this code was originally posted here:
               https://gist.github.com/fivegrant/ef243819e12b1f0ca1c679a2388e038f
"""

# Snag Data \ stole this from my day 8 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.readlines()
  data = [[int(y) for y in x.strip("\n")] for x in raw_data]

class Matrix:
  def __init__(self, body):
    self.body = body
    self.unvisited = []
  
  def __getitem__(self, pair):
    i,j = pair
    if i < 0 or i >= len(self.body) or j < 0 or j >= len(self.body[0]):
      return float('inf') # could also be 10
    else:
      return self.body[i][j]

  def adjacent(self, pair):
    i,j = pair
    neighbors = [(i-1, j),(i+1,j),(i,j-1),(i,j+1)]
    return [self[x] for x in neighbors]

  def basin(self, pair):
    if pair not in self.unvisited: return []
    self.unvisited.remove(pair)
    if self[pair] >= 9: return []
    i,j = pair
    neighbors = [x for x in [(i-1,j),(i+1,j),(i,j-1),(i,j+1)] if self[x] < 9]
    for possible in [x for x in neighbors if x in self.unvisited]:
      neighbors += self.basin(possible)
    return neighbors + [pair]
    
  def is_lowest(self, pair):
    height = self[pair]
    neighbors = self.adjacent(pair)
    compare = lambda x: height < x
    return all(map(compare, neighbors))

  def find_lowest(self):
    rows = range(len(self.body))
    columns = range(len(self.body[0]))
    significant = []
    for r in rows:
      for c in columns:
        pair = (r,c)
        if self.is_lowest(pair):
          significant += [self[pair]]
    return significant
  
  def risk_level(self):
    points = self.find_lowest()
    return [x + 1 for x in points]
  
  def find_basins(self):
    self.unvisited = [ (i, j)
            for i in range(len(self.body))
            for j in range(len(self.body[0]))
    ]
    basins = []
    while len(self.unvisited) > 0:
      basins += [self.basin(self.unvisited[0])]
    return [set(b) for b in basins if len(b) > 0]

  def basin_score(self):
    scores = [len(b) for b in self.find_basins()]
    largest = sorted(scores)[-3:]
    return largest[0] * largest[1] * largest[2]
    
      

matrix = Matrix(data)

# Part I
print(f'part i: {sum(matrix.risk_level())}')

# Part II
print(f'part ii: {matrix.basin_score()}')
