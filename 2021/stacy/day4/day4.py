#!/usr/bin/env python3

"""
--- Day 4: Giant Squid ---

The way I'm thinking over this problem is that we have a few tasks:

* Preprocess data
    * Keep all numbers to be drawn in an array
    * Keep all boards in an array (each board is a matrix)

* Find the winning board
    * Scan through each number and mark it if there is a match, no need to scan further if match is found
    * Keep track of the most recent drawn number

    * Scan the board to see if it 'won' (might be helpful to use numpy for this?)
        * Only do this after the 5th number is drawn
        * Scan each row
        * Scan each column

* Calculate the final score (sum of all unmarked numbers, multiply that with the winning number) 

* To find the losing board, I need to keep track of which boards have won (in an array)

"""

import numpy as np

BOARD_SIZE = 5

def process_input(input_name):
    with open(input_name) as input:
        boards = []
        curr_board = []

        for i, line in enumerate(input):
            if i == 0:
                bingo_numbers = line.strip().split(',')

            if i > 1:
                if line.strip():
                    curr_board.append(line.split())
                if len(curr_board) == BOARD_SIZE:
                    boards.append(curr_board)
                    curr_board = []

        return bingo_numbers, boards


def bingo(elements):
    """
    Accepts either a column set or a row set.
    Returns bool: whether the set only has one element 
                  whether that element is marked
    """
    return len(elements) == 1 and '*' in elements


def mark(board, number):
    """
    Mark board after a number is found.
    """
    return np.where(board == number, '*', board)


def find_board(bingo_numbers, boards, winning):
    """
    A winning board is the board that wins first.
    A losing board is the board that wins last.

    Returns either a winning or losing board.
    """

    last_drawn_num = None
    last_won = []
    has_won = [False] * len(boards)

    for number in bingo_numbers:
        for i, board in enumerate(boards):
            if not has_won[i]:
                board = mark(board, number)
                boards[i] = board
                last_drawn_num = number

                for j in range(BOARD_SIZE):
                    column_set = set(board[:,j])
                    row_set = set(board[j,:])

                    if bingo(column_set) or bingo(row_set):
                        if winning:
                            return board, last_drawn_num
                        last_won = board 
                        has_won[i] = True

    return last_won, last_drawn_num


def calculate_score(winning_board, last_drawn_num):
    total = 0
    for row in winning_board:
        for num in row:
            if num.isdigit():
                total += int(num)

    return total * int(last_drawn_num)


bingo_numbers, boards = process_input('input.txt')

winning_board, winning_num = find_board(bingo_numbers, boards, winning=True)
winning_score = calculate_score(winning_board, winning_num)

losing_board, losing_num = find_board(bingo_numbers, boards, winning=False)
losing_score = calculate_score(losing_board, losing_num)

print("Winning score:", winning_score)
print("Losing score:", losing_score)