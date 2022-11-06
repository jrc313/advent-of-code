import os
import argparse
from functools import lru_cache, wraps, reduce
from time import perf_counter
from itertools import product

FLOOR = "."
VACANT = "L"
OCCUPIED = "#"

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

@lru_cache(maxsize = None)
def get_adjacent_dirs(x, y, w, h):
    coords = []
    for c in product([- 1, 0, 1], repeat = 2):
        xn = c[0] + x
        yn = c[1] + y
        if xn > -1 and xn < w and yn > -1 and yn < h and not(xn == x and yn == y):
            coords.append((c[0], c[1]))
            
    return coords

def is_occupied_project(floor, x, y, w, h, xdir, ydir):
    x, y = x + xdir, y + ydir
    while x > -1 and y > -1 and x < w and y < h:
        if floor[y][x] == OCCUPIED: return 1
        if floor[y][x] == VACANT: return 0
        x, y = x + xdir, y + ydir

    return 0

def get_occupied_adjacent(floor, x, y, w, h):
    adj = get_adjacent_dirs(x, y, w, h)
    return reduce(lambda acc, d: acc + int(floor[y + d[1]][x + d[0]] == OCCUPIED), adj, 0)

def get_occupied_project(floor, x, y, w, h):
    dirs = get_adjacent_dirs(x, y, w, h)
    return reduce(lambda acc, d: acc + is_occupied_project(floor, x, y, w, h, d[0], d[1]), dirs, 0)

def tick(floor, state_func, min_seats, max_seats):
    new_floor = []
    h, w = len(floor), len(floor[0])
    is_stable = True

    for y in range(0, h):
        new_floor.append([])
        for x in range(0, w):
            new_floor[y].append(floor[y][x])
            if not floor[y][x] == FLOOR:
                occupied_adjacent = state_func(floor, x, y, w, h)
                if occupied_adjacent <= min_seats: new_floor[y][x] = OCCUPIED
                if occupied_adjacent >= max_seats: new_floor[y][x] = VACANT
                if not new_floor[y][x] == floor[y][x]: is_stable = False

    return is_stable, new_floor

def count_seats(floor, type):
    return reduce(lambda acc, row: acc + reduce(lambda acc, seat: acc + int(seat == type), row, 0), floor, 0)

def simulate_to_stability(floor, state_func, min_seats, max_seats):
    is_stable = False
    floor = input
    counter = 0
    while not is_stable:
        is_stable, floor = tick(floor, state_func, min_seats, max_seats)
        counter += 1
        
    return counter, count_seats(floor, OCCUPIED)

# Part 1
@timer
def solve1(input):
    iterations, occupied_seats = simulate_to_stability(input, get_occupied_adjacent, 0, 4)
    return f"{iterations} iterations: {occupied_seats}"

# Part 2
@timer
def solve2(input):
    iterations, occupied_seats = simulate_to_stability(input, get_occupied_project, 0, 5)
    return f"{iterations} iterations: {occupied_seats}"


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