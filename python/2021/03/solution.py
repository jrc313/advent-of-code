import os
import argparse
from functools import reduce

# Convert a bit list to an integer using bit shift operations
def bitlist_to_int(bitlist):
    return reduce(lambda i, e: i + (int(e[1]) << int(e[0])), enumerate(reversed(bitlist)), 0)

# Find the most common value at each position in the byte
def reduce_to_common_bits(input):
    width = len(input[0])
    half_count = len(input) / 2
    acc = reduce(lambda acc, line: [a + int(b) for a, b in zip(acc, line)], input, [0] * width)
    return [int(i >= half_count) for i in acc]

# Multiply two bit lists and get an int back
def bit_mul(a, b):
    return bitlist_to_int(a) * bitlist_to_int(b)

# Recursively reduce list based on most common value at each position
def reduce_to_one(input, flip = False):
    i = 0
    while len(input) > 1:
        common = reduce_to_common_bits(list(line[i] for line in input))[0]
        if flip:
            common = int(not(common))
        input = list(filter(lambda line: int(line[i]) == common, input))
        i += 1
    return input[0]

# Part 1
def solve1(input):
    gamma_l = reduce_to_common_bits(input)
    epsilon_l = [int(not(b)) for b in gamma_l]
    return bit_mul(gamma_l, epsilon_l)

# Part 2
def solve2(input):
    o2_l = reduce_to_one(input, False)
    co2_l = reduce_to_one(input, True)
    return bit_mul(o2_l, co2_l)

# Testing, testing
def test():
    return "TODO"

def get_input(filename = "input.txt", line_parser = lambda line: int(line)):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    input = []
    with open(input_path, "r") as file:
        for line in file:
            input.append(line_parser(line.rstrip()))

    return input

def line_parser(line):
    return line

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

input = get_input(line_parser = line_parser)

if args.test:
    print(f"Test: {test()}")
else:
    print(f"Part 1: {solve1(input)}")
    print(f"Part 2: {solve2(input)}")