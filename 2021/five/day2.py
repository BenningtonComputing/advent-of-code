
#!/usr/bin/env python3
"""
day2-2021.py - my solution to day 2 of advent of code 2021.
               the link to the problem is:
               https://adventofcode.com/2021/day/2

               this code was originally posted here:
               https://gist.github.com/fivegrant/c6f265497c7d13e94937a0ee67d519b9 
"""

# Snag Data \ stole this from my day 1 code
import sys
data_path = sys.argv[1]
with open(data_path) as f:
  raw_data = f.read().splitlines()
  raw_data = raw_data[:-1] if len(raw_data[-1]) == 0 else raw_data
  data = [(x,int(y)) for x,y in [i.split() for i in raw_data]]

# Part I
location = [0,0]
def move(instruction):
  if(instruction[0] == 'forward'):
    location[0] += instruction[1]
  else:
    location[1] += instruction[1] if instruction[0] == 'down' \
             else -instruction[1]

[move(x) for x in data]
print(f'part i: {location}')

# Part II

location = [0,0]
aim = 0
def move_faster(instruction):
  global aim 
  if(instruction[0] == 'forward'):
    location[0] += instruction[1]
    location[1] += aim * instruction[1]
  else:
    aim += instruction[1] if instruction[0] == 'down' \
             else -instruction[1]

[move_faster(x) for x in data]
print(f'part ii: {location}')
