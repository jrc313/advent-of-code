import os
import argparse


# Part 1
def solve1(input):
    h = 0
    d = 0
    for command, arg in input:
        if command == "forward":
            h += int(arg)
        if command == "down":
            d += int(arg)
        if command == "up":
            d -= int(arg)
    return f"h: {h}, d: {d}, mul: {h * d}"

# Part 2
def solve2(input):
    h = 0
    a = 0
    d = 0
    for command, arg in input:
        if command == "forward":
            h += int(arg)
            d += a * int(arg)
        if command == "down":
            a += int(arg)
        if command == "up":
            a -= int(arg)
    return f"h: {h}, d: {d}, mul: {h * d}"

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

input = get_input(line_parser = lambda line: line.split())

if args.test:
    print(f"Test: {test()}")
else:
    print(f"Part 1: {solve1(input)}")
    print(f"Part 2: {solve2(input)}")