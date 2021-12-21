'''Advent of Code 2021: Day 13

https://adventofcode.com/2021/day/13

Dec 21, 2021'''

from toolkit import *
import numpy as np
import matplotlib.pyplot as plt

def create_point_set(points):
    """Creates a set of points which are 'on'"""

    point = [i.split(',') for i in points]
    list_ = [(int(i[0]), int(i[1])) for i in point]

    return list_


def fold_up(val, list_):
    """Returns list of points after folding up"""
    new_list = [(i[0], -i[1]%val) for i in list_ if i[1] > val] # points remaining after folding
    upper_half = [i for i in list_ if i[1] < val]
    
    new_list = new_list + upper_half
    new_list = list(set(new_list))
    return new_list


def fold_left(val, list_):
    """Returns list of points after folding up"""
    new_list = [(-i[0]%val, i[1]) for i in list_ if i[0] > val] # points remaining after folding
    upper_half = [i for i in list_ if i[0] < val]
    
    new_list = new_list + upper_half
    new_list = list(set(new_list))
    return new_list


def get_folds(fold_list):
    """Gets folding instructions from fold_list"""
    folds = [i.split() for i in fold_list]
    folds = [i[-1] for i in folds]

    return folds


def interpret_folds(str, point_list):
    """deduces which fold to do"""
    if str[0] == 'y':
        return fold_up(int(str[2:]), point_list)
    else:
        return fold_left(int(str[2:]), point_list)


def create_array(list_):
    """Creates an array from the point list after folds"""
    row = max([int(i[1]) for i in list_]) + 1
    col = max([int(i[0]) for i in list_]) + 1

    empty_array = np.full((row, col),'.')

    for i in list_:
        empty_array[i[1],i[0]] = '#'

    return empty_array


def draw_graph(points):

    plt.figure(figsize=(5,5))
    x = [i[0] for i in points]
    y = [i[1] for i in points]

    X = max(x)
    Y = max(y)

    #plt.xlim(X, 0)
    plt.ylim(Y, 0)
    plt.scatter(x, y)

    plt.show()


def test():
    testfile = inputfile('input_files/test_files/day_13.txt')

    folds = testfile[-2:]
    points = testfile[:-3]
    points = create_point_set(points)
    folds = get_folds(folds)
    points_1 = interpret_folds(folds[0], points)
    points_2 = interpret_folds(folds[1], points_1)
    print(create_array(points_2))
    draw_graph(points_2)
    

    return len(points_1)


assert test() == 17

def main():
    inp = inputfile('input_files/day_13.txt')

    folds = inp[-12:]
    points = inp[:-13]

    points = create_point_set(points)
    print(len(points))
    folds = get_folds(folds)
    
    print(folds[0])
    print('Part 1:',len(interpret_folds(folds[0], points)))

    for i in folds:
        print(i)
        points = interpret_folds(i, points)

    draw_graph(points)


main()