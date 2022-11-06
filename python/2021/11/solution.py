import os
import argparse

def get_adjacent_coords(x, y):
    c = []
    w = 10
    h = 10
    if x > 0: c.append([x - 1, y])
    if x + 1 < w: c.append([x + 1, y])
    if y > 0: c.append([x, y - 1])
    if y + 1 < h: c.append([x, y + 1])
    if x > 0 and y > 0: c.append([x - 1, y - 1])
    if x > 0 and y + 1 < h: c.append([x - 1, y + 1])
    if x + 1 < w and y > 0: c.append([x + 1, y - 1])
    if x + 1 < w and y + 1 < h: c.append([x + 1, y + 1])
    return c

def get_key(x, y):
    return f"{x},{y}"

def tick(data):

    for x, line in enumerate(data):
        for y, o in enumerate(line):
            data[x][y] += 1

    flashes = 0
    no_flashes = False
    iterations = 0
    while not(no_flashes):
        iterations += 1
        no_flashes = True
        for x, line in enumerate(data):
            for y, power in enumerate(line):
                if power == 10:
                    no_flashes = False
                    flashes += 1
                    data[x][y] += 1
                    for c in get_adjacent_coords(x, y):
                        if data[c[0]][c[1]] < 10: data[c[0]][c[1]] += 1
    
    for x, line in enumerate(data):
        for y, o in enumerate(line):
            if data[x][y] > 9:
                data[x][y] = 0

    return flashes

# Part 1
def solve1(input):
    flashes = 0
    for i in range(0, 100):
        flashes += tick(input)

    return flashes


# Part 2
def solve2(input):
    i = 1
    while tick(input) < 100:
        i += 1

    return i



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

input = get_input(filename)
print(f"Part 2: {solve2(input)}")