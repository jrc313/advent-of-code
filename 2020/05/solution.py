import os
import math
import argparse


input_path = os.path.dirname(os.path.realpath(__file__)) + "/input.txt"
input = []
with open(input_path, "r") as file:
    input = file.read().splitlines()

def bsp(instructions, up_inst, top, bottom = 0, verbose = False):
    for char in instructions:
        mid = ((top - bottom) / 2) + bottom
        if char == up_inst:
            mid = math.ceil(mid)
            bottom = mid
        else:
            mid = math.floor(mid)
            top = mid

        if verbose:
            print(f"{instructions} {top} {mid} {bottom}")

        if len(instructions) == 1:
            return mid
        else:
            return bsp(instructions[1:], up_inst, top, bottom, verbose)

seats = {}

def add_seat(row, col, seat_id):
    if not(row in seats):
        seats[row] = {}
    seats[row][col] = seat_id

def get_seat_id(row, col):
    return (row * 8) + col

# Part 1
def solve1():
    seat_ids = []

    for line in input:
        row = bsp(line[0:7], "B", 127)
        col = bsp(line[7:], "R", 7)
        seat_id = (row * 8) + col
        add_seat(row, col, seat_id)
        seat_ids.append(seat_id)
        print(f"{line}: {row}.{col} [{seat_id}]")

    print(f"Max seat id {max(seat_ids)}")

def solve2():
    for row in sorted(seats)[1:-1]:
        prev = -1
        for col in sorted(seats[row]):
            if not(col - prev) == 1:
                missing_seat_col = col - 1
                seat_id = get_seat_id(row, missing_seat_col)
                print(f"{row}.{missing_seat_col} [{seat_id}]")
                return
            prev = col

def test():
    line = "BFFFBBFRRR"
    row = bsp(line[0:7], "B", 127, verbose = True)
    col = bsp(line[7:], "R", 7, verbose = True)
    seat_id = get_seat_id(row, col)
    print(f"{line}: {row}.{col} [{seat_id}]")


parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()
if args.test:
    test()
else:
    solve1()
    solve2()