import os
import argparse
from collections import defaultdict, deque
from itertools import product, combinations
from functools import wraps
from time import perf_counter

dists = []

rotations = [lambda x, y, z: (x, y, z),    lambda x, y, z: (x, z, -y),
             lambda x, y, z: (x, -y, -z),  lambda x, y, z: (x, -z, y),
             lambda x, y, z: (y, -x, z),   lambda x, y, z: (y, z, x),
             lambda x, y, z: (y, x, -z),   lambda x, y, z: (y, -z, -x),
             lambda x, y, z: (-x, -y, z),  lambda x, y, z: (-x, -z, -y),
             lambda x, y, z: (-x, y, -z),  lambda x, y, z: (-x, z, y),
             lambda x, y, z: (-y, x, z),   lambda x, y, z: (-y, -z, x),
             lambda x, y, z: (-y, -x, -z), lambda x, y, z: (-y, z, -x),
             lambda x, y, z: (z, y, -x),   lambda x, y, z: (z, x, y),
             lambda x, y, z: (z, -y, x),   lambda x, y, z: (z, -x, -y),
             lambda x, y, z: (-z, -y, -x), lambda x, y, z: (-z, -x, y),
             lambda x, y, z: (-z, y, x),   lambda x, y, z: (-z, x, -y)]

def timer(func):
    @wraps(func)
    def wrapper_timer(*args, **kwargs):
        s_time = perf_counter()
        result = func(*args, **kwargs)
        e_time = perf_counter()
        r_time = (e_time - s_time) * 1000
        print(f"func {func.__name__!r} ran in {r_time:.3f}ms")
        return result
    return wrapper_timer

def get_survey(input):
    scanners = defaultdict(list)
    i = 0
    for line in input:
        if not line:
            i += 1
            continue
        if line[0:3] == "---": continue
        b = line.split(",")
        scanners[i] += [(int(b[0]), int(b[1]), int(b[2]))]

    return scanners

def sub_tuple(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])

def add_tuple(a, b):
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])

def compare_beacons(s1, s2):
    dists = defaultdict(int)
    for r in rotations:
        for dist in [sub_tuple(p[0], r(*p[1])) for p in product(s1, s2)]:
            dists[dist] += 1
            if dists[dist] == 12: return dist, r

    return False, False

def reorient_beacons(beacons, dist, r):
    for i, b in enumerate(beacons):
        beacons[i] = add_tuple(r(*b), dist)

def get_manhattan_dist(d1, d2):
    x, y, z = sub_tuple(d1, d2)
    return abs(x) + abs(y) + abs(z)

def reorient_scanners(scanners):
    beacons = set()
    visited = set()
    scan_q = deque()
    scan_q.append(0)

    while len(scan_q) > 0:
        current = scan_q.pop()
        visited.add(current)
        beacons.update(scanners[current])
        for i in range(0, len(scanners)):
            if i in visited: continue
            dist, r = compare_beacons(scanners[current], scanners[i])
            if dist:
                reorient_beacons(scanners[i], dist, r)
                scan_q.append(i)
                dists.append(dist)

    return beacons


# Part 1
@timer
def solve1(input):
    scanners = get_survey(input)
    beacons = reorient_scanners(scanners)
    
    return len(beacons)


# Part 2
@timer
def solve2(input):
    max_dist = 0
    for d1, d2 in combinations(dists, 2):
        md = get_manhattan_dist(d1, d2)
        if md > max_dist: max_dist = md

    return max_dist



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