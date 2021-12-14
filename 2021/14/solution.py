import os
import argparse
from collections import defaultdict

def get_polymer_data(input):
    template = input[0]
    polymer_map = {}
    for line in input[2:]:
        l = line.split(" -> ")
        polymer_map[l[0]] = l[1]

    return template, polymer_map

def to_pairs(template):
    pairs = defaultdict(int)
    for i, c in enumerate(template[1:]):
        pairs[template[i] + c] += 1
    
    return pairs

def get_frequency(s):
    freqs = defaultdict(int)
    for c in s: freqs[c] += 1

    return freqs

def polymerise(pairs, freqs, polymer_map):
    new_pairs = defaultdict(int)
    for pair, count in pairs.items():
        insert = polymer_map[pair]
        new_pairs[pair[0] + insert] += count
        new_pairs[insert + pair[1]] += count
        freqs[insert] += count

    return new_pairs, freqs

def polymerise_times(template, polymer_map, times):
    pairs = to_pairs(template)
    freqs = get_frequency(template)
    for _ in range(0, times):
        pairs, freqs = polymerise(pairs, freqs, polymer_map)

    sorted_freqs = sorted(freqs.values())
    return sorted_freqs[-1] - sorted_freqs[0]

# Part 1
def solve1(template, polymer_map):
    return polymerise_times(template, polymer_map, 10)

# Part 2
def solve2(template, polymer_map):
    return polymerise_times(template, polymer_map, 40)


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
template, polymer_map = get_polymer_data(input)

print(f"Part 1: {solve1(template, polymer_map)}")
print(f"Part 2: {solve2(template, polymer_map)}")