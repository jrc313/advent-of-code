import os
import argparse
from itertools import starmap

# Return true if b is deeper than a
def isDeeper(a, b):
    return b > a

# Get pairs of items from iterable
def pairwise(iterable):
    for i in range(1, len(iterable)):
        yield [iterable[i - 1], iterable[i]]

# Calculate rolling 3 sum
def triple_sum(iterable):
    for i in range(2, len(iterable)):
        yield int(iterable[i - 2]) + int(iterable[i - 1]) + int(iterable[i])

# Part 1
def solve1(input):
    answer = sum((starmap(isDeeper, pairwise(input))))
    print(f"{answer}")

# Part 2
def solve2(input):
    sums = list(triple_sum(input))
    answer = answer = sum((starmap(isDeeper, pairwise(sums))))
    print(f"{answer}")

# Testing, testing
def test():
    # TODO
    print(f"")


input_path = os.path.dirname(os.path.realpath(__file__)) + "/input.txt"
input = []
with open(input_path, "r") as file:
    input = file.read().splitlines()

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()
if args.test:
    test()
else:
    solve1(input)
    solve2(input)