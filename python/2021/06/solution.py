import os
import argparse
from functools import reduce

def tick(school):
    fish = school.pop(0)
    school[6] += fish
    school.append(fish)

def build_school(input):
    school = [0] * 9
    for i in input:
        school[i] += 1
    return school

def simulate(school, days):
    for i in range(0, days):
        tick(school)
    return sum(school)

# Part 1
def solve1(school):
    return simulate(school, 80)

# Part 2
def solve2(school):
    return simulate(school, 256 - 80)


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
school = build_school(input)

print(f"Part 1: {solve1(school)}")
print(f"Part 2: {solve2(school)}")