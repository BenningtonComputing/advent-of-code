'''Advent of code 2021: day 4

Swagata'''

from toolkit import *

def test():
    teststring = """7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
    
    22 13 17 11  0
    8  2 23  4 24
    21  9 14 16  7
    6 10  3 18  5
    1 12 20 15 19

    3 15  0  2 22
    9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
    2  0 12  3  7"""

    teststring = teststring.split('\n')
    teststring = treat_input(teststring)
    
    seq = get_seq(teststring)
    boards = get_boards(teststring)

    assert len(get_boards(teststring)) == 3 # checking that there are three boards
    
    assert start_bingo(boards, seq) == 4512

    print(part_two_bingo(boards, seq))

def treat_input(inp):
    
    inp = [i.strip() for i in inp]
    inp = [i for i in inp if i != '']
    return inp


def get_seq(input_):
    seq = input_[0]
    seq = seq.replace(',',' ')
    seq = seq.split()
    seq = turn_list_to_int(seq)
    return seq


def get_boards(input_):
    boards = []
    for i in range(1, len(input_), 5):
        board_i = input_[i:i+5]
        board_i = [turn_list_to_int(i.split()) for i in board_i]
        boards.append(board_i)
    return boards

def start_bingo(boards, sequence):
    boards_ = boards.copy()
    seq = list(reversed(sequence))
    num = seq[-1]
    seq.pop()

    for i in range(len(boards)):
        boards_[i] = bingo_call(num, boards[i])
        if check_board(boards_[i]):
            score = get_score(boards_[i], num)
            return score
    return start_bingo(boards_, list(reversed(seq)))
    


def bingo_call(num, board):
    board_ = board.copy()
    for i in range(5):
        row = board[i]
        board_[i] = [-5 if j == num else j for j in row ]
    return board_


def check_board(board):
    for row in board:
        if sum(row) == -25:
            return True
    for i in range(5):
        col = [board[row][i] for row in range(5)]
        if sum(col) == -25:
            return True
    return False


def get_score(board, num):
    score = 0
    for row in board:
        score += sum([num for num in row if num != -5])
    final = score * num
    return final

def part_two_bingo(boards, sequence, score_list = []):
    boards_ = boards.copy()
    
    if len(sequence) == 0:
        return score_list[-1]
    seq = list(reversed(sequence))
    num = seq[-1]
    
    seq.pop()
    
    for i in range(len(boards)):
        boards_[i] = bingo_call(num, boards[i])
    
    new_boards = [board for board in boards_ if check_board(board) != True]
    
    for i in range(len(boards)):
        if check_board(boards_[i]):
            score = get_score(boards_[i], num)
            score_list.append(score)
    return part_two_bingo(new_boards, list(reversed(seq)), score_list)


def main():
    input = inputfile('input_files/day_4.txt')
    input = treat_input(input)

    print('part 1:', start_bingo(get_boards(input), get_seq(input)))
    print('part 2:', part_two_bingo(get_boards(input), get_seq(input)))

test()
main()