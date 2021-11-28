import os
import argparse


# Part 1
def solve1(input):
    # TODO
    print(f"")

# Part 2
def solve2(input):
    # TODO
    print(f"")

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