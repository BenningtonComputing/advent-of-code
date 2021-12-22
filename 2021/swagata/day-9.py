
from toolkit import *
import numpy as np
import functools

def add_padding(arr):
    rows, columns = len(arr),len(arr[0])
    new_arr = np.full((rows+2, columns +2), '.')
    new_arr[1:rows+1,1:columns+1] = arr
    return new_arr

def part_1(array):
    rows, columns = len(array),len(array[0])
    score = []
    low_points = []
    for row in range(rows):
        for col in range(columns):
            num = array[row][col]
            if num != '.':
                neighbor = get_neighbors(row,col, array)
                neighbor = [int(i) for i in neighbor if i != '.']
                neighbor.append(int(num))
                if min(neighbor) == int(num) and neighbor.count(int(num)) == 1:
                    low_points.append((row, col))
                    score.append(int(num)+1)
    return sum(score), low_points


def get_basin_size(position, arr, check, checked = [], basin_size = 0):
    """Given the position and array, returns the size of basin"""
    if len(check) == 0 and checked != []:
        return (basin_size)
    else:
        neighbor_pos = get_neighbor_pos(position)
        check.extend(neighbor_pos)
        check = list(set(check))
        check_ = check.copy()
        for i in check_:
            if i in set(checked):
                check.remove(i)
                if len(check) == 0 and checked != []:
                    return (basin_size)
            else:
                if array_value(i, arr) == '.':
                    checked.append(i)
                    check.remove(i)
                    if len(check) == 0 and checked != []:
                        return (basin_size)
                elif int(array_value(i, arr)) == 9:
                    checked.append(i)
                    check.remove(i)
                    if len(check) == 0 and checked != []:
                        return (basin_size)
                else:
                    checked.append(i)
                    basin_size += 1
                    check.remove(i)
                    return get_basin_size(i, arr, check,checked, basin_size)



def array_value(postiion, arr):
    """Returns the value at an array from the tuple"""
    row, col = postiion[0], postiion[1]
    value = arr[row, col]
    return value


def get_neighbor_pos(position):
    """Returns the list of neighbor position"""
    x, y = position[0], position[1]
    list_ = [(x+1, y), (x-1,y), (x,y+1), (x, y-1)]
    return list_
    

def test():
    teststring = """2199943210
3987894921
9856789892
8767896789
9899965678"""
    teststring = teststring.split('\n')
    testarray = np.array([turn_list_to_int([j for j in i]) for i in teststring])
    testarray = add_padding(testarray)
    scores_1 = part_1(testarray)
    score_1 = scores_1[0]

    low_points = scores_1[1]
    score_2 = sum([get_basin_size(i, testarray, [i]) for i in low_points])
    return (score_1,score_2)

#print(test())
#assert test() == (15, 35)

def main():
    inp = inputfile('input_files/day_9.txt')
    inp = np.array([turn_list_to_int([j for j in i]) for i in inp])

    inp = add_padding(inp)
    part1 = part_1(inp)
    print('Part 1:', part1[0])

    low_points = part1[1]
    part_2 = [get_basin_size(i, inp, [i]) for i in low_points]
    part_2.sort()
    part_2 = part_2[-3:]
    score_2 = 1
    for i in part_2:
        score_2 = score_2 * i
    print('Part 2:', score_2)


main()