import os
import argparse
from math import sqrt, floor

def parse_coords(input):
    pairs = input[13:].split(", ")
    x = pairs[0][2:].split("..")
    y = pairs[1][2:].split("..")
    return int(x[0]), int(x[1]), int(y[0]), int(y[1])

def inverse_tri(i):
    return (sqrt(1 + 8 * i) - 1) / 2

def lands_in_square(vxy, square):
    xmin, xmax, ymin, ymax = square
    x, y = (0, 0)
    vx, vy = vxy

    while x <= xmax and y >= ymin:
        if x >= xmin and y <= ymax:
            return True
        x += vx
        y += vy

        if vx > 0: vx -= 1
        vy -= 1

    return False

# Part 1
def solve1(input):
    _, _, ymin, _ = parse_coords(input[0])
    vy = abs(ymin) - 1
    return vy * (vy + 1) // 2

# Part 2
def solve2(input):
    xmin, xmax, ymin, ymax = parse_coords(input[0])

    total_coords = 0
    valid_x_min = floor(inverse_tri(xmin))

    for x in range(valid_x_min, xmax + 1):
        for y in range(ymin, abs(ymin) + 1):
            total_coords += int(lands_in_square((x, y), (xmin, xmax, ymin, ymax)))

    return total_coords



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