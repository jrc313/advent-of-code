import os
import argparse
from functools import reduce

def get_adjacent_coords(data, test, i, j):
    c = []
    if i > 0 and test(data[i - 1][j]): c.append([i - 1, j])
    if i + 1 < len(data) and test(data[i + 1][j]): c.append([i + 1, j])
    if j > 0 and test(data[i][j - 1]): c.append([i, j - 1])
    if j + 1 < len(data[0]) and test(data[i][j + 1]): c.append([i, j + 1])
    return c

def get_low_points(data):
    low_points = []
    for i, line in enumerate(data):
        for j, n in enumerate(line):
            adj = get_adjacent_coords(data, lambda a: n >= a, i, j)
            if len(adj) == 0:
                low_points.append([i, j])
    return low_points

def build_basin(data, low_point, seen = []):
    seen.append(low_point)
    basin = 1
    for a in get_adjacent_coords(data, lambda a: a < 9, low_point[0], low_point[1]):
        if a not in seen:
            basin += build_basin(data, a, seen)
    return basin


# Part 1
def solve1(input):
    return reduce(lambda acc, p: acc + input[p[0]][p[1]] + 1, get_low_points(input), 0)


# Part 2
def solve2(input):
    basins = [build_basin(input, p) for p in get_low_points(input)]
    return reduce(lambda acc, b: b * acc, sorted(basins)[-3:], 1)


def get_input(filename):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    return [[int(c) for c in line.rstrip()] for line in open(input_path)]

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

filename = "input.txt"
if args.test:
    filename = "test.txt"

input = get_input(filename)

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")