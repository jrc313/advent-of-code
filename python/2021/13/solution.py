import os
import argparse

def get_grid_and_instructions(input):
    grid = set()
    instructions = []
    grid_done = False

    for line in input:
        if not line:
            grid_done = True
        elif grid_done:
            fold = line[11:].split("=")
            instructions += [(fold[0], int(fold[1]))]
        else:
            point = line.split(",")
            grid.add((int(point[0]), int(point[1])))

    return grid, instructions

def print_grid(grid):
    max_xy = list(map(max, zip(*grid)))
    for y in range(0, max_xy[1] + 1):
        for x in range(0, max_xy[0] + 1):
            if (x, y) in grid: print("😎", end = "")
            else: print("⬜️", end = "")
        print("")

def fold_point(p, f_point):
    if p < f_point: return p
    return (2 * f_point) - p

def get_folder(axis, f_point):
    if axis == "x":
        return lambda x, y: (fold_point(x, f_point), y)
    return lambda x, y: (x, fold_point(y, f_point))

def fold_grid(grid, instruction):
    folder = get_folder(*instruction)
    new_grid = set()
    for (x, y) in grid:
        new_grid.add(folder(x, y))

    return new_grid

# Part 1
def solve1(grid, instructions):
    grid = fold_grid(grid, instructions[0])
    return(len(grid))

# Part 2
def solve2(grid, instructions):
    for instruction in instructions:
        grid = fold_grid(grid, instruction)

    print_grid(grid)

    return "See above"



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
grid, instructions = get_grid_and_instructions(input)


print(f"Part 1: {solve1(grid, instructions)}")
print(f"Part 2: {solve2(grid, instructions)}")