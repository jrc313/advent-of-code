import os
import argparse
from functools import wraps
from time import perf_counter
from collections import namedtuple

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

Command = namedtuple("Command", ["op", "arg1", "arg2"])

alu = {
    "add": lambda a, b: a + b,
    "mul": lambda a, b: a * b,
    "div": lambda a, b: a // b,
    "mod": lambda a, b: a % b,
    "eql": lambda a, b: int(a == b)
}
def reset_memory():
    return (0, 0, 0, 0)

def parse_prog(input):
    prog = []
    i = -1
    for line in input:
        if not line: continue
        inst = line.split(" ")
        if inst[0] == "inp":
            i += 1
            prog.append([])
            continue

        prog[i].append(Command(alu[inst[0]], inst[1], inst[2]))

    return prog

def run_monad(prog, memory:tuple[int], monad_num:int, num:int):
    monad = prog[monad_num]
    mem = list(memory)
    mem[0] = num
    for c in monad:
        if c.arg2 in ["w", "x", "y", "z"]:
            arg2 = mem[ord(c.arg2) - ord("w")]
        else:
            arg2 = int(c.arg2)
        mem[ord(c.arg1) - ord("w")] = c.op(mem[ord(c.arg1) - ord("w")], arg2)

    return tuple(mem)

def test_number(input, num):
    prog = parse_prog(input)
    num_s = str(num)
    memory = reset_memory()
    if "0" in num_s: return (1, 1, 1, 1)
    for i, n in enumerate(num_s):
        memory = run_monad(prog, memory, i, int(n))

    return memory[3] == 0


def get_components(input):
    get_component = lambda i, n: int(input[i * 18 + n].split(" ")[2])
    for i in range(0, 14):
        yield get_component(i, 4), get_component(i, 5), get_component(i, 15)


# Part 1
@timer
def solve1(input):
    stack = []
    counter = 0

    num = [0] * 14
    for z, x, y in get_components(input):
        if z == 1:
            stack.append((counter, y))

        else:
            prev, prev_y = stack.pop()
            diff = x + prev_y
            if diff < 0:
                num[prev] = 9
                num[counter] = 9 + diff
            else:
                num[prev] = 9 - diff
                num[counter] = 9
        
        counter += 1

    biggest = int("".join(map(str, num)))
    is_valid_num = test_number(input, biggest)
    return f"{is_valid_num}: {biggest}"


# Part 2
@timer
def solve2(input):
    stack = []
    counter = 0

    num = [0] * 14
    for z, x, y in get_components(input):
        if z == 1:
            stack.append((counter, y))

        else:
            prev, prev_y = stack.pop()
            diff = x + prev_y
            if diff < 0:
                num[counter] = 1
                num[prev] = 1 - diff
            else:
                num[counter] = 1 + diff
                num[prev] = 1
        
        counter += 1

    smallest = int("".join(map(str, num)))
    is_valid_num = test_number(input, smallest)
    return f"{is_valid_num}: {smallest}"


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