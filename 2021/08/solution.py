import os
import argparse
from functools import reduce

known_lengths = {2: 1, 3: 7, 4: 4, 7: 8}

def sort_s(s):
    return "".join(sorted(s))

def parse_input(input):
    return [l.replace(" | ", " ").split(" ") for l in input]

def signal_to_bitmask(signal):
    return sum([1 << ord(c) - 97 for c in signal])

def test_signal(bitmask, tests, patterns, default):
    for num, test in tests:
        if test(patterns, bitmask): return num
    return default

def test_signal_list(signal_list, tests, patterns, signal_map, default):
    for signal in signal_list:
        bitmask = signal_to_bitmask(signal)
        num = test_signal(bitmask, tests, patterns, default)
        patterns[num] = bitmask
        signal_map[signal] = num

# Part 1
def solve1(input):
    total = 0
    for d in input:
        items = [n for n in d[-4:] if len(n) in known_lengths.keys()]
        total += len(items)

    return total

# Part 2
def solve2(input):

    total = 0

    for line in input:
        patterns = [0] * 10
        signal_map = {}
        preamble = [sort_s(signal) for signal in line[0:-4]]
        data = line[-4:]

        for signal in [s for s in preamble if len(s) in known_lengths.keys()]:
            num = known_lengths[len(signal)]
            patterns[num] = signal_to_bitmask(signal)
            signal_map[signal] = num

        bit13 = patterns[1] ^ patterns[4]
        bit13_test = lambda _, bitmask: (bit13 & bitmask) == bit13

        five_tests = [
            (3, lambda patterns, bitmask: patterns[1] & bitmask == patterns[1]),
            (5, bit13_test)
        ]

        six_tests = [
            (6, lambda patterns, bitmask: not(patterns[1] & bitmask == patterns[1])),
            (9, bit13_test)
        ]

        test_signal_list([s for s in preamble if len(s) == 5], five_tests, patterns, signal_map, 2)
        test_signal_list([s for s in preamble if len(s) == 6], six_tests, patterns, signal_map, 0)

        number = reduce(lambda acc, signal: (10 * acc) + signal_map[sort_s(signal)], data, 0)
        total += number

    return total


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
lines = parse_input(input)

print(f"Part 1: {solve1(lines)}")
print(f"Part 2: {solve2(lines)}")