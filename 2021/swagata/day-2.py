'''Advent of Code 2021: day 2

https://adventofcode.com/2021/day/2

Swagata'''

#from toolkit import *

from toolkit import inputfile


teststring = """forward 5
down 5
forward 8
up 3
down 8
forward 2"""

teststring = teststring.split('\n')
def treat_input(list_):
    """takes in input list, returns a list of list with direction and magnitude"""
    input_ = [i.split() for i in list_]
    return input_

def get_position(list_):
    """takes in treated list and returns a tuple with horizontal and depth position, and product of them"""
    hori = sum([int(i[1]) for i in list_ if i[0] == 'forward' ])
    depth_up = sum([-int(i[1]) for i in list_ if i[0] == 'up' ])
    depth_down = sum([int(i[1]) for i in list_ if i[0] == 'down' ])
    depth = depth_up + depth_down
    return hori, depth, hori * depth

assert get_position(treat_input(teststring))[2] == 150

input = inputfile('input_files/day_2.txt')

def part_2(list_):
    """Gives answer for second part with a brute force approach"""
    hori = 0
    depth = 0
    aim = 0
    for i in treat_input(list_):
        if i[0] == 'forward':
            hori += int(i[1])
            depth += aim * int(i[1])
        elif i[0] == 'up':
            aim -= int(i[1])
        else:
            aim += int(i[1])
        
    return hori, depth, hori * depth

assert part_2(teststring)[2] == 900

def main():
    print('Part 1:', get_position(treat_input(input))[2])
    print('Part 2:', part_2(input)[2])

main()