import os
import argparse
from functools import wraps
from time import perf_counter

def timer(func):
    @wraps(func)
    def wrapper_timer(*args, **kwargs):
        s_time = perf_counter()
        result = func(*args, **kwargs)
        e_time = perf_counter()
        r_time = e_time - s_time
        print(f"func {func.__name__!r} ran in {r_time:.5f}s")
        return result
    return wrapper_timer


def get_adjacent(w, h, x, y, char):
    if char == ">":
        new_x = x + 1 if x + 1 < w else 0
        return new_x, y
    else:
        new_y = y + 1 if y + 1 < h else 0
        return x, new_y

def tick(input, move_char):
    w = len(input[0])
    h = len(input)
    output = []
    for _ in range(0, h):
        output.append(list("." * w))
    has_moves = False

    for y in range(0, h):
        for x in range(0, w):
            char = input[y][x]
            if not char == ".":
                new_x, new_y = get_adjacent(w, h, x, y, char)
                if input[new_y][new_x] == "." and char == move_char:
                    output[new_y][new_x] = char
                    has_moves = True
                else:
                    output[y][x] = char

    return has_moves, output


def print_board(input):
    for line in input:
        print("".join(line))

    print()

# Part 1
@timer
def solve1(input):
    i = 0
    while True:
        has_moves_right, input = tick(input, ">")
        has_moves_down, input = tick(input, "v")
        i += 1
        if not (has_moves_right or has_moves_down): break

    return i

# Part 2
@timer
def solve2(input):
    # TODO
    return "TODO"



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