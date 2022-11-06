import os
import argparse

def get_sums(preamble_nums):
    sums = {}
    for i in preamble_nums:
        for j in preamble_nums:
            if not(i == j):
                sums[i + j] = 1
    return list(sums.keys())


# Part 1
def solve1(input):
    invalid = []
    preamble = 25
    for i in range(preamble, len(input)):
        sums = get_sums(input[i - preamble:i + preamble - 1])
        if not(input[i] in sums):
            invalid.append(input[i])
            
    return invalid

# Part 2
def solve2(input):
    target = solve1(input)[0]
    search_space = [i for i in input if i < target and not(i == target)]
    for gap in range(1, len(search_space)):
        for i in range(0, len(search_space) - gap):
            to_sum = search_space[i:i + gap]
            if sum(to_sum) == target:
                return min(to_sum) + max(to_sum)


    return "Nada"

# Testing, testing
def test():
    # TODO
    return "TODO"



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
input = [int(i) for i in input]

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")