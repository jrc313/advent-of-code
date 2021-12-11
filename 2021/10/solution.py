import os
import argparse
from collections import deque
from functools import reduce
from statistics import median

pairs = {"(": ")", "[": "]", "{": "}", "<": ">"}
corrupt_scores = {")": 3, "]": 57, "}": 1197, ">": 25137}
valid_scores = {"(": 1, "[": 2, "{": 3, "<": 4}

valid_stacks = []

def get_stack_score(stack):
    scores = [valid_scores[c] for c in reversed(stack)]
    return reduce(lambda acc, i: (5 * acc) + i, scores, 0)

# Part 1
def solve1(input):

    p1_score = 0

    for line in input:
        stack = deque()
        is_corrupt = False
        first_illegal = ""
        for c in line:
            if c in pairs.keys(): stack.append(c)
            else:
                if not(c == pairs[stack.pop()]):
                    is_corrupt = True
                    if first_illegal == "": first_illegal = c
                    if c == first_illegal: p1_score += corrupt_scores[c]
        if not(is_corrupt):
            valid_stacks.append(stack)

    return p1_score

def solve2(input):
    return median([get_stack_score(stack) for stack in valid_stacks])


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

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")