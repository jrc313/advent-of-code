import os
import argparse
from functools import reduce

def gamma_reducer(acc, line):
    for i in range(len(line)):
        acc[i] += int(line[i])
    return acc

def bitlist_to_string(bitlist):
    return "".join([str(b) for b in bitlist])

def bitlist_to_int(bitlist):
    return int(bitlist_to_string(bitlist), 2)

def get_gamma_l(input):
    width = len(input[0])
    count = len(input)
    half_count = count / 2

    acc = reduce(lambda acc, line: gamma_reducer(acc, line), input, [0] * width)
    return [int(i >= half_count) for i in acc]

# Part 1
def solve1(input):
    gamma_l = get_gamma_l(input)
    epsilon_l = [int(not(b)) for b in gamma_l]

    gamma_s = bitlist_to_string(gamma_l)
    epsilon_s = bitlist_to_string(epsilon_l)

    gamma_i = bitlist_to_int(gamma_s)
    epsilon_i = bitlist_to_int(epsilon_s)

    answer = gamma_i * epsilon_i

    return f"gamma: {gamma_i}, epsilon: {epsilon_i}, answer: {answer}"


def reduce_to_one(input, low = False):
    i = 0
    while len(input) > 1:
        common = get_gamma_l(input)[i]
        if low:
            common = int(not(common))
        input = list(filter(lambda line: int(line[i]) == common, input))
        i += 1
    return input[0]

# Part 2
def solve2(input):

    o2_l = reduce_to_one(input, False)
    co2_l = reduce_to_one(input, True)

    o2_i = bitlist_to_int(o2_l)
    co2_i = bitlist_to_int(co2_l)

    lsr = o2_i * co2_i

    return f"o2: {o2_i}, co2: {co2_i}, lsr: {lsr}"

# Testing, testing
def test():
    input = """00100
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
01010""".splitlines()
    return solve2(input)


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