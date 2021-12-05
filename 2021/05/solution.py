import os
import argparse

def get_coords(input):
    pairs = [line.split(" -> ") for line in input]
    pairs = [[points[0].split(","), points[1].split(",")] for points in pairs]
    return [[[int(pair[0][0]), int(pair[0][1])], [int(pair[1][0]), int(pair[1][1])]] for pair in pairs]

def non_diagonal(coords):
    return filter(lambda p: p[0][0] == p[1][0] or p[0][1] == p[1][1], coords)

def get_dir(a, b):
    if a == b: return 0
    return int((b - a) / abs(b - a))

def expand_line(pair):
    p1 = [pair[0][0], pair[0][1]]
    p2 = pair[1]
    xdir = get_dir(p1[0], p2[0])
    ydir = get_dir(p1[1], p2[1])
    points = [f"{p1[0]},{p1[1]}"]
    while not(p1[0] == p2[0] and p1[1] == p2[1]):
        p1[0] += xdir
        p1[1] += ydir
        points.append(f"{p1[0]},{p1[1]}")

    return points

# Part 1
def solve1(coords):
    points = {}
    revisit = {}
    for pair in non_diagonal(coords):
        for p in expand_line(pair):
            if p in points.keys():
                points[p] += 1
                revisit[p] = 1
            else:
                points[p] = 1

    return len(revisit)

# Part 2
def solve2(coords):
    points = {}
    revisit = {}
    for pair in coords:
        for p in expand_line(pair):
            if p in points.keys():
                points[p] += 1
                revisit[p] = 1
            else:
                points[p] = 1

    return len(revisit)


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
coords = get_coords(input)


print(f"Part 1: {solve1(coords)}")
print(f"Part 2: {solve2(coords)}")