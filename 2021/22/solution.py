import os
import argparse
import re
import math
from functools import wraps
from time import perf_counter
from collections import namedtuple

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

Cube = namedtuple("Cube", ["x1", "y1", "z1", "x2", "y2", "z2", "is_on"])

def parse_input(input):
    cubes = []
    axes = ["x", "y", "z"]
    axis_pattern = lambda axis: f"{axis}=(?P<{axis}1>-?[0-9]+)\.\.(?P<{axis}2>-?[0-9]+)"
    pattern = "^(?P<status>[onf]+) " + ",".join([axis_pattern(axis) for axis in axes]) + "$"

    g = lambda match, name: int(match.group(name))
    for line in input:
        m = re.search(pattern, line)
        cube = Cube(g(m, "x1"), g(m, "y1"), g(m, "z1"),
                    g(m, "x2"), g(m, "y2"), g(m, "z2"),
                    is_on = m.group("status") == "on")
        cubes.append(cube)
        
    return cubes

def get_intersect(c1, c2) -> Cube:
    i = Cube(max(c1.x1, c2.x1), max(c1.y1, c2.y1), max(c1.z1, c2.z1),
                min(c1.x2, c2.x2), min(c1.y2, c2.y2), min(c1.z2, c2.z2),
                False)
    return i.x1 <= i.x2 and i.y1 <= i.y2 and i.z1 <= i.z2, i

def subtract_cube(c:Cube, c2:Cube):
    has_intersect, i = get_intersect(c, c2)
    if not has_intersect: return [c]

    cubes = []
    add_cube = lambda x1, y1, z1, x2, y2, z2: cubes.append(Cube(x1, y1, z1, x2, y2, z2, False))

    if i.x1 > c.x1: add_cube(c.x1, c.y1, c.z1, i.x1 - 1, c.y2, c.z2)
    if c.x2 > i.x2: add_cube(i.x2 + 1, c.y1, c.z1, c.x2, c.y2, c.z2)
    if i.y1 > c.y1: add_cube(i.x1, c.y1, c.z1, i.x2, i.y1 - 1, c.z2)
    if c.y2 > i.y2: add_cube(i.x1, i.y2 + 1, c.z1, i.x2, c.y2, c.z2)
    if i.z1 > c.z1: add_cube(i.x1, i.y1, c.z1, i.x2, i.y2, i.z1 - 1)
    if c.z2 > i.z2: add_cube(i.x1, i.y1, i.z2 + 1, i.x2, i.y2, c.z2)

    return cubes

def get_cube_volume(cube:Cube):
    return (1 + cube.x2 - cube.x1) * (1 + cube.y2 - cube.y1) * (1 + cube.z2 - cube.z1)

def reboot_reactor(cubes: list[Cube], rmin:int = -math.inf, rmax:int = math.inf):
    range_cube = Cube(rmin, rmin, rmin, rmax, rmax, rmax, False)
    reactor:list[Cube] = [cubes[0]]
    
    for cube in cubes[1:]:
        is_in_range, _ = get_intersect(cube, range_cube)
        if is_in_range:
            new_reactor:list[Cube] = []
            for p_cube in reactor:
                new_reactor += subtract_cube(p_cube, cube)
            if cube.is_on: new_reactor += [cube]
            reactor = new_reactor

    return sum([get_cube_volume(c) for c in reactor])


# Part 1
@timer
def solve1(cube:list[Cube]):
    return reboot_reactor(cube, -50, 50)

# Part 2
@timer
def solve2(cube:list[Cube]):
    return reboot_reactor(cube)


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

print(f"Part 1: {solve1(parse_input(input))}")
print(f"Part 2: {solve2(parse_input(input))}")