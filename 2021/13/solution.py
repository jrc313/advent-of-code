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
    mx = 0
    my = 0

    for x, y in grid:
        if x > mx: mx = x
        if y > my: my = y

    for y in range(0, my + 1):
        for x in range(0, mx + 1):
            if (x, y) in grid:
                print("#", end = "")
            else:
                print(" ", end = "")
        print("")

def fold_point(p, n):
    if p < n: return p
    return (2 * n) - p

def fold_grid(grid, fold_instruction):

    axis, n = fold_instruction

    new_grid = set()
    for (x, y) in grid:
        new_p = (0, 0)
        if axis == "x":
            new_p = (fold_point(x, n), y)
        else:
            new_p = (x, fold_point(y, n))

        new_grid.add(new_p)

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