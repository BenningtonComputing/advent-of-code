#!/usr/bin/env python3

"""
Advent of Code!

--- Day 3: Binary Diagnostic ---

This one is tougher than I thought!
This is not too elegant... I really should get comfortable with map.
Might shorten this a lot more based on other Python soltions.

"""
def process_input(input_name):
    with open(input_name) as input:
        return [line.strip() for line in input]


def multiply_binary(x, y):
    return int(x, 2) * int(y, 2)


def power_consumption(input):
    binary_length = len(input[0])
    bit_dict = {'0': 0, '1': 0}
    common = [bit_dict.copy() for _ in range(binary_length)]

    for binary in input:
        for i, bit in enumerate(binary):
            common[i][bit] += 1

    # most common bits
    gamma = '0b'
    # least common bits
    epsilon = '0b'

    # max() Parameters
    # iterable - an iterable such as list, tuple, set, dictionary, etc.
    # key (optional) - key function where the iterables are passed and comparison is performed based on its return value

    for bit_data in common:
        gamma += max(bit_data, key=bit_data.get)
        epsilon += min(bit_data, key=bit_data.get)

    return multiply_binary(gamma, epsilon)


def rating_generator(numbers, rating_name):
    index = 0

    while len(numbers) > 1:
        zeros = []
        ones = []

        for number in numbers:
            if number[index] == '0':
                zeros.append(number)
            else:
                ones.append(number)

        if rating_name == 'O2':
            numbers = max([ones, zeros], key=len)
        elif rating_name == 'CO2':
            numbers = min([zeros, ones], key=len)
        else:
            break
        
        index += 1

    return numbers[0]


def life_support(input):
    oxygen_generator = rating_generator(input, 'O2')
    CO2_scrubber = rating_generator(input, 'CO2')

    return multiply_binary(oxygen_generator, CO2_scrubber)


input = process_input('input.txt')
print("Power consumption:", power_consumption(input))
print("Life support:", life_support(input))



