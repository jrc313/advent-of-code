import os
import argparse
from collections import deque
from functools import reduce
from statistics import median

pairs = {"(": ")", "[": "]", "{": "}", "<": ">"}
corrupt_scores = {")": 3, "]": 57, "}": 1197, ">": 25137}
valid_scores = {"(": 1, "[": 2, "{": 3, "<": 4}

# Part 1
def solve(input):
    p1_score = 0

    valid = []
    valid_stacks = []

    for line in input:
        stack = deque()
        is_corrupt = False
        first_illegal = ""
        for c in line:
            if c in pairs.keys(): stack.append(c)
            else:
                a = pairs[stack.pop()]
                if not(a == c):
                    is_corrupt = True
                    if first_illegal == "":
                        first_illegal = c
                    if c == first_illegal:
                        p1_score += corrupt_scores[c]
        if not(is_corrupt):
            valid.append(line)
            valid_stacks.append(stack)

    p2_scores = []
    for stack in valid_stacks:
        scores = [valid_scores[c] for c in reversed(stack)]
        p2_scores.append(reduce(lambda acc, i: (5 * acc) + i, scores, 0))
    p2_score = median(p2_scores)
    
    return {"P1": p1_score, "P2": p2_score}




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

print(f"Part 1 and 2: {solve(input)}")