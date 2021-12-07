'''Advent of Code 2021: day 6

https://adventofcode.com/2021/day/6

Swagata'''



from typing import Counter
from toolkit import *
import collections
    

def get_initial(inp):
    """Turns the initial population into a dictionary"""
    inp = inp.split(',')
    inp = turn_list_to_int(inp)
    dict = Counter(inp)
    return dict


def simulate(dict, days):
    """efficient way of doing the simulation"""
    new_dict = collections.defaultdict(lambda:0)
    if days == 0:
        return dict
    else:
        for keys in dict:
            new_dict[keys - 1] = dict[keys]
            
        if -1 in new_dict.keys():
            if new_dict[-1] != 0:
                new_dict[6] += new_dict[-1]
                new_dict[8] += new_dict[-1]
                new_dict[-1] = 0
        days -= 1
        return simulate(new_dict, days)

def get_pop_from_dict(dict):
    """returns the total population from the dictionary"""
    return sum([dict[i] for i in dict])
    
def test():
    teststring = '3,4,3,1,2'

    score = get_pop_from_dict(simulate(get_initial(teststring), 80))
    score_2 = get_pop_from_dict(simulate(get_initial(teststring), 256))

    return (score, score_2)

assert test() == (5934, 26984457539)

def main():
    inp = inputfile('input_files/day_6.txt', lines=False)

    print('Part 2:',get_pop_from_dict(simulate(get_initial(inp), 80)))
    print('Part 2:',get_pop_from_dict(simulate(get_initial(inp), 256)))


main()