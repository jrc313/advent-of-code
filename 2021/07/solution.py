import os
import argparse
from statistics import median

def get_distance(n):
    return int((n * n/2) + (n/2))

# Part 1
def solve1(input):
    med = int(median(input))
    return sum([abs(i - med) for i in input])

def sum_fuel(input, dest):
    return sum([get_distance(abs(i - dest)) for i in input])

# Part 2
def solve2(input):
    input.sort()
    return min([sum([get_distance(abs(i - n)) for i in input]) for n in range(input[0], input[-1])])


def get_input(filename):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    return [line.rstrip() for line in open(input_path)]

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

filename = "input.txt"
if args.test:
    filename = "test.txt"

input = get_input(filename)
input = [int(i) for i in input[0].split(",")]

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")