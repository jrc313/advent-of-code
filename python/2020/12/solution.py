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

# Part 1
@timer
def solve1(input):
    # TODO
    return "TODO"

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