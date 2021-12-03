'''Advent of Code 2021

Day 1:'''

from toolkit import *

input = inputfile('input_files\day_1.txt')
input = [int(i) for i in input]

testcase = '''199
200
208
210
200
207
240
269
260
263'''

testcase = [int(i) for i in testcase.split()]

def larger_than_prev_count(input_):
    """Takes in input file which is a list of numbers
    Returns the number of occurences of a measurement being larger than the previous measurement"""
    sum = 0
    for i in range(1, len(input_)):
        if input_[i] > input_[i-1]:
            sum += 1
    return sum

assert larger_than_prev_count(testcase) == 7


######################
#part 2
######################

def make_slide_list(list_):
    """takes in a list of number and creates a new list according to the sliding rule"""
    new_list = []
    for i in range(len(list_)-2):
        new_list.append(list_[i]+list_[i+1]+list_[i+2])

    return new_list

assert larger_than_prev_count(make_slide_list(testcase)) == 5


def main():
    print('Part 1:', larger_than_prev_count(input))
    print('Part 2:', larger_than_prev_count(make_slide_list(input)))

main()

