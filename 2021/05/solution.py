import os
import argparse

def split_coord(coord_s):
    coord = coord_s.split(",")
    return [int(coord[0]), int(coord[1])]

def get_coords(input):
    pairs = [line.split(" -> ") for line in input]
    return [[split_coord(coords[0]), split_coord(coords[1])] for coords in pairs]

def non_diagonal(coords):
    return filter(lambda p: p[0][0] == p[1][0] or p[0][1] == p[1][1], coords)

def get_dir(a, b):
    if a == b: return 0
    return int((b - a) / abs(b - a))

def get_key(p):
    return f"{p[0]},{p[1]}"

def expand_line(p1, p2):
    p = [p1[0], p1[1]]
    xdir = get_dir(p1[0], p2[0])
    ydir = get_dir(p1[1], p2[1])
    yield get_key(p)
    while not(p[0] == p2[0] and p[1] == p2[1]):
        p[0] += xdir
        p[1] += ydir
        yield get_key(p)

def get_overlapping_points(coords):
    points = {}
    for pair in coords:
        for p in expand_line(pair[0], pair[1]):
            points[p] = points.get(p, 0) + 1

    return [p for p in points if points[p] > 1]

# Part 1
def solve1(coords):
    return len(get_overlapping_points(non_diagonal(coords)))

# Part 2
def solve2(coords):
    return len(get_overlapping_points(coords))


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