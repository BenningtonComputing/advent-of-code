#!/usr/bin/env python3
"""
day4-2021.py - my solution to day 4 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/4


               this code was originally posted here:
               https://gist.github.com/fivegrant/cf7fd281cbe10fce375b1c1825883bcf
"""
# Snag Data \ stole this from my day 3 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.read().split("\n\n")
  nums = [int(x) for x in raw_data[0].split(",")]
  raw_boards = [list(map(int, x)) 
                for x in [x.strip("\n").split() for x in raw_data[1:]]]

# Model the bingo subsystem
class Board:
  def __init__(self, body, n): # 1D list makes each n elements a row.
    self.dim = n
    self.body = body
    self.chosen = []

  def __getitem__(self, key):
    i,j = key
    return self.body[i*self.dim + j]
  
  def index(self, value):
    val_index = self.body.index(value)
    return (val_index // self.dim, val_index % self.dim)
  
  def mark(self, value):
    if value in self.body:
      self.chosen.append(self.index(value))
  
  def has_won(self):
    indices = list(range(self.dim))
    rows = self.dim in [[i for i,j in self.chosen].count(i) for i in indices]
    columns = self.dim in [[j for i,j in self.chosen].count(j) for j in indices]
    diagonal = all([(i,i) in self.chosen for i in indices]) | \
               all([(self.dim - (1 + i),i) in self.chosen for i in indices])
    return rows | columns # | diagonal ;/ "diagonals don't count"
    
  def score(self):
    last_drawn = self[self.chosen[-1]]
    return last_drawn * sum([x for x in self.body 
                             if self.index(x) not in self.chosen])
  
def find_winning(data,n):
  boards = [Board(board,n) for board in data]
  score_list = []
  for pick in nums:
    for i in range(len(boards)):
      boards[i].mark(pick)
      if boards[i].has_won() and i not in [i for i,j in score_list]:
        score_list.append((i,boards[i].score()))
  return score_list

      
# Part I
print(f'part i: {find_winning(raw_boards,5)[0]}')

# Part II
print(f'part ii: {find_winning(raw_boards,5)[-1]}')
