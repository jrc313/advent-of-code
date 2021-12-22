import os
import argparse
from functools import lru_cache, wraps
from time import perf_counter
from itertools import product
from collections import defaultdict

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

def get_start_pos(input):
    return [int(input[0][28:]), int(input[1][28:])]

def wrap_num(num, wrap_point):
    return (num - 1) % wrap_point + 1

def roll(die, pos):
    d1 = wrap_num(die + 1, 100)
    d2 = wrap_num(die + 2, 100)
    d3 = wrap_num(die + 3, 100)
    pos = wrap_num(pos + d1 + d2 + d3, 10)
    return d3, pos

roll_universes = defaultdict(int)
def calculate_roll_universes(sides):
    roll_range = range(1, sides + 1)
    possible_rolls = [sum(roll) for roll in product(roll_range, roll_range, roll_range)]
    for roll in possible_rolls:
        roll_universes[roll] += 1


@lru_cache(maxsize = None)
def roll_quantum(p, die = 0, s = (0, 0), player = 1):
    pos = list(p)
    score = list(s)

    if die > 0:
        pos[player] = wrap_num(pos[player] + die, 10)
        score[player] += pos[player]
        if score[player] > 20:
            wins = [0, 0]
            wins[player] = 1
            return tuple(wins)

    other_player = int(not player)
    p1win = p2win = 0

    for d, universes in roll_universes.items():
        new_p1win, new_p2win = roll_quantum((pos[0], pos[1]), d, (score[0], score[1]), other_player)
        p1win += new_p1win * universes
        p2win += new_p2win * universes
    
    return p1win, p2win

# Part 1
@timer
def solve1(input):
    rolls = player = die = 0
    pos = get_start_pos(input)
    score = [0, 0]

    while score[0] < 1000 and score[1] < 1000:
        die, new_pos = roll(die, pos[player])
        pos[player] = new_pos
        score[player] += new_pos
        rolls += 3
        player = not player

    return rolls * score[player]

# Part 2
@timer
def solve2(input):
    calculate_roll_universes(3)
    pos = get_start_pos(input)
    wins = roll_quantum(tuple(pos))
    return max(wins)



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