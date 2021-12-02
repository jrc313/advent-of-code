import functools
import os
import argparse
 
H = 0
D = 1
A = 2
 
# Part 1
def solve1(input):
    proc = {"forward": lambda ub, arg: [ub[H] + arg, ub[D]],
            "down": lambda ub, arg: [ub[H], ub[D] + arg],
            "up": lambda ub, arg: [ub[H], ub[D] - arg]}
   
    ub = functools.reduce(lambda ub, item: proc[item[0]](ub, int(item[1])), input, [0, 0, 0])
    return f"h: {ub[H]}, d: {ub[D]}, mul: {ub[H] * ub[D]}"
 
# Part 2
def solve2(input):
    proc = {"forward": lambda ub, arg: [ub[H] + arg, ub[D] + (ub[A] * arg), ub[A]],
            "down": lambda ub, arg: [ub[H], ub[D], ub[A] + arg],
            "up": lambda ub, arg: [ub[H], ub[D], ub[A] - arg]}
   
    ub = functools.reduce(lambda ub, item: proc[item[0]](ub, int(item[1])), input, [0, 0, 0])
    return f"h: {ub[H]}, d: {ub[D]}, mul: {ub[H] * ub[D]}"
 
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
 

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()
 
input = get_input(line_parser = lambda line: line.split())
 
if args.test:
    print(f"Test: {test()}")
else:
    print(f"Part 1: {solve1(input)}")
    print(f"Part 2: {solve2(input)}")