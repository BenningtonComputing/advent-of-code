'''
Advent of Code 2021: day 3

https://adventofcode.com/2021/day/3

Swagata'''

from toolkit import *



def get_rate(input_):
    """Returns gamma rate and epsilon rate"""
    gamma = ''
    epsilon = ''
    n = len(input_[0]) # obtaining the length of the binary number
    for i in range(n):
        list_ = [dig[i] for dig in input_]
        gamma += max(set(list_), key = list_.count)
        epsilon += min(set(list_), key = list_.count)

    return gamma, epsilon



def part_1_res(rates):
    """Takes in tuple with gamma and epsilon rate.
    Converts the rate from binary to decimal and returns their product"""
    return binary_to_decimal(rates[0]) * binary_to_decimal(rates[1])

##################
# part 2
##################

def get_generator_rating(input_, bit_position = 0, curr_rating = ''):
    """Returns generator rating"""
    inp = input_.copy()
    if len(inp) == 1:
        return inp[0]
    else:
        list_ = [dig[bit_position] for dig in input_]   
        if sum(turn_list_to_int(list_)) >= len(inp)/2:                 # check bit criteria                 
            curr_rating += '1'                                          # update generator rating
            new_inp = [dig for dig in inp if dig[bit_position] == '1']  # getting the subset we are interested in
            return get_generator_rating(new_inp, bit_position + 1, curr_rating)        
        else:
            curr_rating += '0'
            new_inp = [dig for dig in inp if dig[bit_position] == '0']
            return get_generator_rating(new_inp, bit_position + 1, curr_rating) 


def get_scrubber_rating(input_, bit_position = 0, curr_rating = ''):
    """Returns scrubber rating"""
    inp = input_.copy()
    if len(inp) == 1:
        return inp[0]
    else:
        list_ = [dig[bit_position] for dig in input_]   
        if sum(turn_list_to_int(list_)) < len(inp)/2:                 # check bit criteria                 
            curr_rating += '1'                                          # update generator rating
            new_inp = [dig for dig in inp if dig[bit_position] == '1']  # getting the subset we are interested in
            return get_scrubber_rating(new_inp, bit_position + 1, curr_rating)        
        else:
            curr_rating += '0'
            new_inp = [dig for dig in inp if dig[bit_position] == '0']
            return get_scrubber_rating(new_inp, bit_position + 1, curr_rating) 


def part_2_res(generator, scrubber):
    """Takes in generator and oxygen rating.
    Converts them from binary to decimal and returns their product"""
    return binary_to_decimal(generator) * binary_to_decimal(scrubber)

def test():
    ##part 1
    teststring = """00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010"""

    teststring = teststring.split()

    assert get_rate(teststring) == ('10110', '01001')
    assert part_1_res(get_rate(teststring)) == 198
    
    assert get_generator_rating(teststring) == '10111'
    assert get_scrubber_rating(teststring) == '01010'



def main():
    input = inputfile('input_files/day_3.txt')
    print('Part 1:', part_1_res(get_rate(input)))

    print('Part 2:', part_2_res(get_generator_rating(input), get_scrubber_rating(input)))


test()
main()


    


