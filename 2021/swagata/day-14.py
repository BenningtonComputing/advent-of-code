'''Advent of Code 2021: Day 14

https://adventofcode.com/2021/day/14

Dec 21, 2021'''

from toolkit import *
from functools import partial
from collections import Counter, defaultdict

def get_pairs(str):
    """Gets list of pairs from the string"""
    pairs = []
    for i in range(len(str) - 1):
        pairs.append(str[i:i+2])

    return pairs


def replace_pairs(pair, dict_):
    """Replaces a pair with letter inserted"""
    str = pair[0] + dict_[pair] + pair[1]

    return str


def create_dic(pairs):
    """Creates a dictionary with pairs as keys and the letter to be inserted as value"""

    keys = [i[:2] for i in pairs]
    val = [i[-1] for i in pairs]

    dict_ = dict(zip(keys, val))

    return dict_, set(val)


def part_1(str, dict_, n):
    """iterates replace_pairs n times"""
    pairs = get_pairs(str)
    for i in range(n):
        print(i)
        pairs = map(partial(replace_pairs, dict_ = dict_), pairs)
        new_pairs = []
        for i in pairs:
            new_pairs.append(i[:2])
            new_pairs.append(i[1:])
        pairs = new_pairs
    
    to_str = [i[0] for i in new_pairs]
    str = ''.join(to_str) + str[-1]
    return str


def get_count(str_, letters):
    """gets counts of each letter"""
    dict_ = defaultdict(lambda: 0)
    for letter in letters:
        dict_[letter] = str_.count(letter)

    score = max(dict_.values()) - min(dict_.values())

    return score

def test():
    
    teststring = inputfile('input_files/test_files/day_14.txt')

    template = teststring[0]
    pairs = teststring[2:]

    dict_ = create_dic(pairs)
    letters = dict_[1]
    dict_ = dict_[0]

    str_ = part_1(template, dict_, 10)

    score_1 = get_count(str_, letters)

    return score_1

#assert test() == 1588

def main():
    inp = inputfile('input_files/day_14.txt')

    template = inp[0]
    pairs = inp[2:]

    dict_ = create_dic(pairs)
    letters = dict_[1]
    dict_ = dict_[0]

    str_ = part_1(template, dict_, 10)

    print('Part 1:', get_count(str_, letters))

#main()

############################################ 
###### Part 2. Need a more efficient way

def create_eff_dict(pairs):
    """Creates a new dict where each pair correspoinds to a list of two other pairs
    
    e.g. CH -> B will correspond to {'CH' : ['CB', BH']}"""

    dict_ = create_dic(pairs)[0]

    new_dict = defaultdict(lambda: 0)
    for key in dict_:
        new_dict[key] = [key[0] + dict_[key], dict_[key] + key[1]]

    return new_dict


def make_polymer(starting_dict, reference_dict_, n):
    """Creates the polymer by doing n steps"""
    if n == 0:
        return starting_dict
    else:
        #print(starting_dict)
        n_dict = starting_dict.copy()
        for key in starting_dict.keys():
            val = starting_dict[key]
            n_dict[key] -= val
            for j in reference_dict_[key]:
                n_dict[j] += val
        n -= 1
        return make_polymer(n_dict, reference_dict_, n)


def starting_dict(template):
    """Creates starting dict from template"""
    pairs = get_pairs(template)
    dict_ = Counter(pairs)

    return dict_


def count(dict_, template):
    """Counts the letters given the dictionary"""

    count_dict = defaultdict(lambda: 0)

    count_dict[template[0]] = 1
    count_dict[template[-1]] = 1

    for key in dict_.keys():
        val = dict_[key]
        for i in key:
            count_dict[i] += val

    most = max(count_dict.values()) // 2
    least = min(count_dict.values()) // 2
    score = most - least
    return score

            


def test2():
    teststring = inputfile('input_files/test_files/day_14.txt')

    template = teststring[0]
    pairs = teststring[2:]

    dict_ = create_eff_dict(pairs)

    starting_dic = starting_dict(template)
    final_dict = make_polymer(starting_dic, dict_, 40)

    score = count(final_dict, template)

    return score

assert test2() == 2188189693529



def main2():
    inp = inputfile('input_files/day_14.txt')

    template = inp[0]
    pairs = inp[2:]

    dict_ = create_eff_dict(pairs)

    starting_dic = starting_dict(template)
    final_dict = make_polymer(starting_dic, dict_, 40)

    score = count(final_dict, template)

    return score

print(main2())

