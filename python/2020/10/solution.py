from collections import defaultdict
import os
import argparse
from collections import defaultdict

# Part 1
def solve1(input):

    adapters = sorted(input + [0])

    j1 = 0
    j3 = 1
    for i in range(1, len(adapters)):
        prev = adapters[i - 1]
        curr = adapters[i]
        diff = abs(prev - curr)
        if diff == 1: j1 += 1
        if diff == 3: j3 += 1

    return j1 * j3
    

# Part 2
def solve2(input):
    adapters = sorted(input)

    paths = defaultdict(int, {0: 1})
    for adapter in adapters:
        for n in range(1, 4):
            if adapter - n >= 0:
                paths[adapter] += paths[adapter - n]
    
    return paths[adapters[-1]]
    


def get_input(filename, parser = None):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    if parser is None:
        return [line.rstrip() for line in open(input_path)]
    
    return [parser(line.rstrip()) for line in open(input_path)]

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

filename = "input.txt"
if args.test:
    filename = "test.txt"

input = get_input(filename, lambda line: int(line))

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")


