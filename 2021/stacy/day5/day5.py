#!/usr/bin/env python3

"""
--- Day 5: Hydrothermal Venture ---

This one was also definitely tougher than I thought!
Especially because matrices are one of my weak points...
I had to draw out a matrix in order to visualize the 
diagonal lines lol.

But learning about how to use numpy is fun...!

"""

import numpy as np


def process_input(input_name):
    """
    Returns the processed input as well as the max size of the ocean matrix
    """
    with open(input_name) as input:
        max_size = 0
        processed = []

        for line in input:
            points = line.strip().split(' -> ')
            line_array = []

            for point in points:
                point = point.split(',')
                p1, p2 = int(point[0]), int(point[1])
                line_array.append((p1, p2))
                max_size = max(max_size, p1, p2)

            processed.append(line_array)

        return processed, max_size + 1


def calculate_dangerous_points(input, ocean_size):

    ocean = np.zeros((ocean_size, ocean_size), dtype=np.int8)

    for line in input:
        line.sort()
        x1, y1 = line[0][0], line[0][1]
        x2, y2 = line[1][0], line[1][1]

        if y1 == y2:
            ocean[y1][x1:x2+1] = list(map(lambda x: x + 1, ocean[y1][x1:x2+1]))

        elif x1 == x2:
            ocean[:,x1][y1:y2+1] = list(map(lambda x: x + 1, ocean[:,x1][y1:y2+1]))

        else:
            if y1 < y2:
                while x1 <= x2 and y1 <= y2:
                    ocean[y1][x1] += 1
                    x1 += 1
                    y1 += 1
            else:
                while x1 <= x2 and y1 >= y2:
                    ocean[y1][x1] += 1
                    x1 += 1
                    y1 -= 1

    count = np.count_nonzero(ocean > 1)
    return count


input, ocean_size = process_input('input.txt')
dangerous_points = calculate_dangerous_points(input, ocean_size)
print("Number of dangerous points:", dangerous_points)