import os
import argparse
from collections import defaultdict
from operator import itemgetter

def get_polymer_data(input):
    template = input[0]
    polymer_map = {}
    for line in input[2:]:
        l = line.split(" -> ")
        pair = l[0]
        insert = l[1]
        polymer_map[pair] = insert

    return template, polymer_map

def to_pairs(template):
    pairs = {}
    for i in range(1, len(template)):
        pair = template[i - 1] + template[i]
        pairs[pair] = pairs.get(pair, 0) + 1
    
    return pairs

def get_frequency(s):
    freqs = defaultdict(int)
    for c in s: freqs[c] += 1

    return freqs

def polymerise(pairs, freqs, polymer_map):
    new_pairs = defaultdict(int)
    for pair in pairs:
        insert = polymer_map[pair]
        new_pairs[pair[0] + insert] += pairs[pair]
        new_pairs[insert + pair[1]] += pairs[pair]
        freqs[insert] += pairs[pair]

    return new_pairs, freqs

def polymerise_times(template, polymer_map, times):
    pairs = to_pairs(template)
    freqs = get_frequency(template)
    for _ in range(0, times):
        pairs, freqs = polymerise(pairs, freqs, polymer_map)

    max_char = max(freqs.items(), key=itemgetter(1))
    min_char = min(freqs.items(), key=itemgetter(1))

    return max_char[1] - min_char[1]

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