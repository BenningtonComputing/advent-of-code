#!/usr/bin/env python3

"""
Advent of Code!

--- Day 2: Dive! ---

Now doing advent of code day 2 in-between working on finals...
I sure hope the puzzles don't ramp up too much the first few days!

"""

def process_input(input_name):
  with open('input.txt') as input:
    return input.readlines()

def calculate_pos(input, has_aim=False):

  aim, horizontal, depth = 0, 0, 0

  for line in input:
    split_line = line.split()
    command = split_line[0]
    value = int(split_line[1])

    if command == 'forward':
      horizontal += value
      depth += aim * value
    elif command == 'down':
      aim += value
    elif command == 'up':
      aim -= value

  if has_aim:
    return horizontal * depth
  else:
    return horizontal * aim

input = process_input('input.txt')
p1 = calculate_pos(input)
p2 = calculate_pos(input, True)

print('Part 1:', p1)
print('Part 2:', p2)