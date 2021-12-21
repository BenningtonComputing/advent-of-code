'''Advent of Code 2021: day 10

https://adventofcode.com/2021/day/10

Swagata'''
from toolkit import *


def find_corrupted(list_, part_two = False):
    """checks if a list is corrupted or not. If corrupted, it returns the first incorrect closing character
    else returns None"""
    opening = {'(', '{', '[', '<'}
    closing = {')':'(', '}':'{', ']':'[', '>':'<'}
    stack = []
    for i in list_:
        if i in opening:
            stack.append(i)
        elif i in set(closing.keys()):
            if closing[i] == stack[-1]:
                stack.pop()
            else:
                if part_two:
                    return False
                if not part_two:    
                    return i
    if part_two:
        return stack


def get_error_score(inp):
    """returns the error score for an input"""
    score_dict = {')':3, ']': 57, '}' : 1197, '>': 25137}
    score_list = [find_corrupted(i) for i in inp]
    return sum([score_dict[i] for i in score_list if i != None])

assert find_corrupted('{([(<{}[<>[]}>{[]{[(<()>') == '}'
assert find_corrupted('[(()[<>])]({[<{<<[]>>(') == None


def part_two_score(inp):
    """finds score for part 2"""
    score_list = [find_corrupted(i, part_two=True) for i in inp]
    score_list = [i for i in score_list if i != False]
    score = [get_score_two(i) for i in score_list]
    score.sort()
    return score[len(score)//2]


def get_score_two(list_):
    """gets the score for each line for part 2"""
    score_dict = {'(': 1, '[':2, '{':3, '<':4}
    score = 0
    score_list = [list_.pop() for i in range(len(list_))]
    for i in score_list:
        score = score * 5
        score += score_dict[i]
    return score


def test():
    teststring = """[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"""
    teststring = teststring.split('\n')
    testlist = [[i for i in j] for j in teststring]

    score_1 = get_error_score(testlist)
    score_2 = part_two_score(testlist)
    return (score_1, score_2)

assert test() == (26397, 288957)

def main():
    inp = inputfile('input_files/day_10.txt')
    inp = [[i for i in j] for j in inp]

    print('Part 1:', get_error_score(inp))
    print('Part 2:', part_two_score(inp))


main()

