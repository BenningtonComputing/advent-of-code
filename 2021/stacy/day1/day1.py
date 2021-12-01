#!/usr/bin/env python3

"""
Advent of Code!

--- Day 1: Sonar Sweep ---

Looking forward to discovering more tricks within Python!
Although solving the puzzles in as few lines as possible might prove 
too challenging...

I'll probably play with learning Python more deeply for real
after finals (if my interest still persists!)

"""

def process_input(input_name):
  numbers = []
  with open(input_name) as input:
    for line in input:
      numbers.append(int(line))

  return numbers


def part1(lines):
  curr_num = lines[0]
  increased_times = 0

  for number in lines:
    if number > curr_num:
      increased_times += 1
    curr_num = number

  print("Part 1:", increased_times)


def part2(lines):
  curr_num = sum(lines[0:3])
  increased_times = 0

  for i in range(len(lines) - 2):
    number = sum(lines[i:i+3])
    if number > curr_num:
      increased_times += 1
    curr_num = number

  print("Part 2:", increased_times)


lines = process_input("input.txt")
part1(lines)
part2(lines)
