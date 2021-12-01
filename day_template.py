import os
import argparse


# Part 1
def solve1(input):
    # TODO
    return "TODO"

# Part 2
def solve2(input):
    # TODO
    return "TODO"

# Testing, testing
def test():
    # TODO
    return "TODO"


def get_input(filename = "input.txt", line_parser = lambda line: int(line)):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    input = []
    with open(input_path, "r") as file:
        for line in file:
            input.append(line_parser(line.rstrip()))

    return input


parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

input = get_input()

if args.test:
    print(f"Test: {test()}")
else:
    print(f"Part 1: {solve1(input)}")
    print(f"Part 2: {solve2(input)}")