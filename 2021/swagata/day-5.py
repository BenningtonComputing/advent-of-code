'''Advent of Code 2021: day 5

https://adventofcode.com/2021/day/5

Swagata'''

from typing import Counter
from toolkit import *

def treat_input(inp):
    """Takes in the input as a list of lines,
    returns a list of list containing the two coordinates for vent liens"""
    inp = [i.split(' -> ') for i in inp]
    inp = [[str_to_tup(i) for i in j] for j in inp]
    return inp


def get_lattice_points(tup1, tup2, check_diagonals = True):
    """Returns a list of points which lie in a line defined by two endpoints"""
    x1, y1 = tup1[0], tup1[1]
    x2, y2 = tup2[0], tup2[1]
    # for horizontal lines, y values are same
    if y1 == y2:
        if x1 <= x2:
            points = [(i, y1) for i in range(x1, x2 + 1)]
            return points
        else:
            points = [(i, y1) for i in range(x2, x1 + 1)]
            return points
    # for vertical points, x values are same
    elif x1 == x2:
        if y1 <= y2:
            points = [(x1, i) for i in range(y1, y2 + 1)]
            return points
        else:
            points = [(x1, i) for i in range(y2, y1 + 1)]
            return points
    elif check_diagonals:
    # diagonal lines
        slope = (y2-y1)/(x2-x1)
        y_int = y1 - slope*x1
        # getting the poitns
        if x1 <= x2:
            points = [(i, int(slope * i + y_int)) for i in range(x1, x2 + 1) if (slope * i + y_int).is_integer()]
            return points
        else:
            points = [(i, int(slope * i + y_int)) for i in range(x2, x1 + 1) if (slope * i + y_int).is_integer()]
            return points

assert get_lattice_points((2,3), (3,3)) == [(2,3),(3,3)]
assert get_lattice_points((2,2), (2,6)) == [(2,2),(2,3),(2,4),(2,5),(2,6)]
assert get_lattice_points((1,1), (4,4)) == [(1,1),(2,2),(3,3),(4,4,)]


def get_points_list(inp, diagonal):
    """creates a list of points where vent is present, including duplicates"""
    list_ = []
    for i in inp:
        if get_lattice_points(i[0], i[1], diagonal) != None:
            list_.extend(get_lattice_points(i[0], i[1], diagonal))

    return list_

def get_score(list_):
    """Takes in list of points, creates a dictionary with points and frequency of vent
    returns the number of points with more than 1 vents"""
    import collections
    count = Counter(list_)
    num = sum([1 for i in count if count[i] > 1])
    return num



def test():
    testinput = """0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2"""
    testinput = testinput.split('\n')
    testinput = treat_input(testinput)

    list_ = get_points_list(testinput, diagonal= False)
    score_1 = get_score(list_)
    
    return score_1

assert test() == 5

def main():
    inp = inputfile('input_files/day_5.txt')
    inp = treat_input(inp)

    #part 1
    list_ = get_points_list(inp, diagonal = False)
    print('Part 1:', get_score(list_))

    # part 2
    list_2 = get_points_list(inp, diagonal = True)
    print('Part 2:', get_score(list_2))

main()