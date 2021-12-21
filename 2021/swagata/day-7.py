'''Advent of Code 2021: day 7

https://adventofcode.com/2021/day/7

Swagata'''

from toolkit import *

def treat_input(str):
    return turn_list_to_int(str.split(','))

def find_min(guess, list_):
    """finds the position at which minimum fuel is used and returns the fuel amount"""
    fuel_for_guess = fuel_used(guess, list_)
    fuel_guess_up = fuel_used(guess + 1, list_)
    fuel_guess_down = fuel_used(guess - 1, list_)
    if (fuel_for_guess < fuel_guess_down)  and (fuel_for_guess < fuel_guess_up):
        return fuel_for_guess
    elif fuel_for_guess > fuel_guess_up:
        return find_min(guess + 1, list_)
    elif fuel_for_guess > fuel_guess_down:
        return find_min(guess - 1, list_)


def fuel_used(pos, list_):
    """gives the fuel amount for a specific position"""
    return sum([abs(pos - i) for i in list_])

## part 2

def part_2_fuel(pos, list_):
    """gives the fuel amount for a specific position according to rules of part 2""" 
    fuel = [(abs(pos - i)*(abs(pos-i)+1))/2 for i in list_]
    return sum(fuel)

assert part_2_fuel(5,[16]) == 66

def part_2_min(guess, list_):
    """finds the position at which minimum fuel is used and returns the fuel amount"""
    fuel_for_guess = part_2_fuel(guess, list_)
    fuel_guess_up = part_2_fuel(guess + 1, list_)
    fuel_guess_down = part_2_fuel(guess - 1, list_)
    if (fuel_for_guess < fuel_guess_down)  and (fuel_for_guess < fuel_guess_up):
        return fuel_for_guess
    elif fuel_for_guess > fuel_guess_up:
        return part_2_min(guess + 1, list_)
    elif fuel_for_guess > fuel_guess_down:
        return part_2_min(guess - 1, list_)


def test():
    teststring = '16,1,2,0,4,2,7,1,2,14'
    teststring = treat_input(teststring)
    
    score = find_min(1, teststring)
    score_2 = part_2_min(1, teststring)
    return (score, score_2)

assert test() == (37, 168)



def main():
    inp = inputfile('input_files/day_7.txt', lines=False)
    inp = treat_input(inp)

    print('Part 1: ', find_min(1, inp))
    print('Part 2: ', part_2_min(1, inp))

main()
