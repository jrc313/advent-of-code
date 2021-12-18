import os
import argparse
from typing import Union
from math import floor, ceil
from itertools import permutations

def add_adjacent_number(snail: list, num: int, pos: int, dir:int = 1) -> None:
    snail_len:int = len(snail)
    pos += dir

    while pos > -1 and pos < snail_len:
        if isinstance(snail[pos], int):
            snail[pos] += num
            return
        pos += dir

def add_snails(snails: list):
    snail_count: int = len(snails)
    snail:list = snails[0]
    for i in range(1, snail_count):
        next_snail: list = snails[i]
        snail = ["["] + snail + next_snail + ["]"]
        snail = reduce_snail(snail)

    return snail

def reduce_snail(snail: list) -> list:
    while True:
        has_exploded, snail = try_explode(snail)
        if not has_exploded:
            has_split, snail = try_split(snail)
            if not has_split: # no more reductions
                return snail


def try_explode(snail: list) -> tuple[bool, list]:
    i: int = 0
    c: Union[int, str]
    depth: int = 0
    prev: str = ""
    snail_len: int = len(snail)

    while i < snail_len:
        c = snail[i]
        if c == "[": depth += 1
        if c == "]": depth -= 1
        if isinstance(c, int) and isinstance(prev, int):
            if depth > 4:
                add_adjacent_number(snail, prev, i - 1, -1)
                add_adjacent_number(snail, c, i, 1)
                snail = snail[0:i - 2] + [0] + snail[i + 2:]
                return True, snail
        
        i += 1
        prev = c

    return False, snail


def try_split(snail: list) -> tuple[bool, list]:
    i: int = 0
    c: Union[int, str]
    snail_len: int = len(snail)

    while i < snail_len:
        c = snail[i]
        i += 1
        if isinstance(c, int) and c > 9:
            #print(f"Splitting {c} at {i}")
            new_pair = ["[", floor(c / 2), ceil(c / 2), "]"]
            snail = snail[0:i - 1] + new_pair + snail[i:]
            return True, snail

    return False, snail

def snail_to_list(snail: str) -> list:
    snail_l: list = []
    i: int = 0
    c: str
    snail_len: int = len(snail)

    while i < snail_len:
        c = snail[i]
        i += 1
        if c == ",": continue
        if c == "[" or c == "]": snail_l.append(c)
        else:
            while snail[i].isnumeric():
                c += snail[i]
                i += 1
            snail_l.append(int(c))

    return snail_l

def snail_to_str(snail:str) -> None:
    c: Union[int, str]
    prev: str = ""
    s: str = ""

    for c in snail:
        if isinstance(prev, int) and not c == "]": s += ","
        if isinstance(c, int) and prev == "]": s += ","
        if prev == "]" and c == "[": s += ","

        s += str(c)
        prev = c

    return s

def snail_magnitude(snail:list) -> int:
    snail_s = snail_to_str(snail)
    snail_s = snail_s.replace(",", "+2*").replace("[", "(3*").replace("]", ")")

    return eval(snail_s)

# Part 1
def solve1(input: list) -> int:
    snails: list = [snail_to_list(snail) for snail in input if snail]
    snail:list = add_snails(snails)
    return snail_magnitude(snail)

# Part 2
def solve2(input: list) -> int:
    largest_mag:int = 0
    snails: list = [snail_to_list(snail) for snail in input if snail]

    a: int
    b: int
    r:list = range(0, len(snails))
    for a, b in permutations(r, 2):
        snail:list = add_snails([snails[a], snails[b]])
        mag:int = snail_magnitude(snail)
        if mag > largest_mag: largest_mag = mag

    return largest_mag



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