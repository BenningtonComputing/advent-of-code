'''Advent of Code 2021: day 11

https://adventofcode.com/2021/day/11

Swagata - 12/14/2021'''

import numpy as np
from toolkit import *

def add_one(arr):
    """Increases every value by 1"""
    rows, columns = arr.shape[0], arr.shape[1]
    flash_list = []
    for row in range(rows):
        for col in range(columns):
            val = arr[row, col]
            if val != '.':
                if int(val) == 9:
                    flash_list.append((row, col))
                    arr[row,col] = int(val) + 1
                else:
                    arr[row,col] = int(val) + 1

    return arr, flash_list


def update_neighbors(arr, flash_list, flashed = []):
    """Updates the nieghbors of the points in the flash list"""
    if len(flash_list) == 0:
        return arr
    else:
        flash_ = flash_list.copy()
        point = flash_[-1]
        flash_.pop()
        if point in set(flashed):
            return update_neighbors(arr, flash_, flashed)
        else:   
            flashed.append(point)        
            neighbors = all_neighbors(point[0], point[1], arr)
            neighbors = [i for i in neighbors if array_value(i, arr) != '.']
            for neighbor in neighbors:
                x, y = neighbor[0], neighbor[1]
                arr[x,y] = int(array_value(neighbor, arr)) + 1
                if int(arr[x,y]) > 9:
                    flash_.append((x,y))
            return update_neighbors(arr, flash_, flashed)


def count_flash(arr):
    """counts the number of flashed in a step"""
    flash = 0
    rows, columns = arr.shape[0], arr.shape[1]
    for row in range(rows):
        for col in range(columns):
            if arr[row,col] != '.' and int(arr[row,col]) > 9:
                flash += 1
                arr[row, col] = 0
    return arr, flash


def check_all_flash(arr):
    """Checks if all flash"""
    rows, columns = arr.shape[0], arr.shape[1]
    for row in range(rows):
        for col in range(columns):
            if arr[row, col] != '.':
                if int(arr[row,col]) != 0:
                    return False
    return True
    
def iterate(arr, n):
    total_flashes = 0
    for i in range(n):
        
        step = add_one(arr)
        arr = step[0]
        
        list_ = step[1]
        arr = update_neighbors(arr,list_,[])
        update = count_flash(arr)   # counts the flash, and turns value to 0
        arr = update[0]
        total_flashes += update[1]
        if check_all_flash(arr):
            return i
        
    return total_flashes

def test():
    teststring = """5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"""
    
    teststring = teststring.split('\n')
    testarray = list_to_arr(teststring)

    testarray = add_padding(testarray, '.')


    score_1 = iterate(testarray, 200)
    print(score_1)
    return score_1

#assert test() == 1656
test()
def main():
    inp = inputfile('input_files/day_11.txt')
    inp = list_to_arr(inp)
    inp = add_padding(inp, '.')

    print('Part 1:', iterate(inp, 300))

main()