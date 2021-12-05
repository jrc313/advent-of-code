import os
import argparse

INST = 0
ARG = 1

def parse_input(input):
    return [[line[0:3], int(line[4:])] for line in input]

def process_line(line, pos, acc):
    inst = line[INST]
    arg = line[ARG]
    if inst == "acc":
        acc += arg
    if inst == "jmp":
        pos += arg
    else:
        pos += 1
    return [pos, acc]

def run_program(program):
    prev_pos = 0
    pos = 0
    acc = 0
    visited = []
    while pos < len(program):
        if pos in visited:
            # Infinite Loop!
            return {"prev": prev_pos, "curr": pos, "acc": acc}
        visited.append(pos)
        prev_pos = pos
        pos, acc = process_line(program[pos], pos, acc)
    return {"prev": prev_pos, "curr": pos, "acc": acc}

def toggle_instruction(inst):
    switch = {"jmp": "nop", "nop": "jmp", "acc": "acc"}
    return switch[inst]

def copy_program(program):
    return [[inst, arg] for inst, arg in program]

# Part 1
def solve1(program):
    return run_program(program)

# Part 2
def solve2(program):
    target = len(program) - 1

    for i in range(0, target):
        new_program = copy_program(program)
        new_program[i][INST] = toggle_instruction(new_program[i][INST])
        result = run_program(new_program)
        if result["curr"] >= target:
            return result

    return

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
p = parse_input(input)

print(f"Part 1: {solve1(p)}")
print(f"Part 2: {solve2(p)}")