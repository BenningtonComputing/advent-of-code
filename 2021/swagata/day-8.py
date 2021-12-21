'''Advent of Code 2021: day 8

https://adventofcode.com/2021/day/8

Swagata'''
from typing import DefaultDict
from toolkit import *
import re
import collections

d = {0:'abcefg', 1:'cf', 2:'acdeg', 3:'acdfg',4:'bcdf', 5:'abdfg', 6:'abdefg', 7:'acf',8:'abcdefg', 9:'abcdfg'}



def treat_part1(inp):
    """"treats the input for part 1"""
    inp = [i.split(' | ') for i in inp]
    inp = [i[1] for i in inp] 
    return inp


def part_1(inp):
    """takes in list of string after | and returns the result"""
    inp = [i.split() for i in inp]
    inp_ = []
    for i in inp:
        inp_ += i
    inp_ = [len(i) for i in inp_]
    score = sum([1 for i in inp_ if (i == 2) or (i == 3) or (i == 4) or (i == 7)])
    return score

def treat_part2(inp):
    """gets the first part of the code"""
    inp = [i.split(' | ') for i in inp]
    inp = [i[0] for i in inp] 
    return inp


def decode(inp):
    """decodes the first part of the input and returns a dictionary
    
    original = {0:'abcefg', 1:'cf', 2:'acdeg', 3:'acdfg',4:'bcdf', 5:'abdfg', 6:'abdefg', 7:'acf',8:'abcdefg', 9:'abcdfg'}
    original character count = {'a': 8, 'b': 6, 'c': 8, 'd': 7, 'e': 4, 'f': 9, 'g': 7}"""
    inp = [i.split() for i in inp]
    all_key = []
    for i in inp:
        key =DefaultDict(lambda:0)
        code = set(i)
        length2 = ''
        length3 = ''
        length4 = ''
        for j in code:
            if len(j) == 2:
                length2 = j
            elif len(j) == 3:
                length3 = j
            elif len(j) == 4:
                length4 = j
        key['a'] = re.sub(f'[{length2}]', '', length3)
        dict = get_count(i)
        for k in dict:
            if dict[k] == 9:
                key['f'] = k
            elif dict[k] == 4:
                key['e'] = k
            elif dict[k] == 6:
                key['b'] = k
            elif k != key['a'] and dict[k] == 8:
                key['c'] = k
        poss_d = re.sub(f'[{length2}]', '', length4)
        key_b  = key['b']
        key['d'] = re.sub(f'[{key_b}]','',poss_d)
        for k in dict:
            if k != key['d'] and dict[k] == 7:
                key['g'] = k
        all_key.append(key)
    
    return all_key

def solve_part2(list_code, list_dict):
    """solves part 2.
    list_code = list of second part of the input (after delimeter), treat_part1(inp)
    list_dict = list of dict of code"""
    score_string = []
    main_key = {'abcefg':0,'cf':1, 'acdeg':2, 'acdfg':3,'bcdf':4,'abdfg':5,'abdefg':6,'acf':7,'abcdefg':8,'abcdfg':9}
    for i in range(len(list_code)):
        key = list_dict[i]
        code = list_code[i].split()
        num = ''
        for j in code:
            st = ''
            for k in j:
                st += get_key(k, key)
            st = ''.join(sorted(st))
            num += str(main_key[st])
        score_string.append(int(num))
    return sum(score_string)


def get_key(val, my_dict):
    for key, value in my_dict.items():
         if val == value:
             return key

def get_count(list_):
    """gives a dictionary showing how many times a character appears"""
    st =  ''
    for i in list_:
        st += i
    new_d = {}
    for i in 'abcdefg':
        new_d[i] = st.count(i)
    return new_d
print(get_count(['be', 'cfbegad', 'cbdgef', 'fgaecd', 'cgeb', 'fdcge', 'agebfd', 'fecdb', 'fabcd', 'edb']))

def test():
    teststring = """be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"""
    testlist = teststring.split('\n')
    
    testlist_1 = treat_part1(testlist)
    result_1 = part_1(testlist_1)
    dict_for_2 = decode(treat_part2(testlist))

    result_2 = solve_part2(testlist_1, dict_for_2)
    return (result_1, result_2)

assert test() == (26, 61229)

def main():
    inp = inputfile('input_files/day_8.txt')
    print('Part 1: ', part_1(treat_part1(inp)))
    dict_2 = decode(treat_part2(inp))
    print('Part 2:', solve_part2(treat_part1(inp), dict_2))

main()