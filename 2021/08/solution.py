import os
import argparse

def parse_input(input):
    return [l.replace(" | ", " ").split(" ") for l in input]

def signal_to_bitmask(signal):
    return sum([1 << ord(c) - 97 for c in signal])

# Part 1
def solve1(input):
    total = 0
    for d in input:
        items = [n for n in d[-4:] if len(n) in [2, 3, 4, 7]]
        total += len(items)

    return total

# Part 2
def solve2(input):

    total = 0

    for line in input:
        patterns = [0] * 10
        signal_map = {}
        preamble = ["".join(sorted(signal)) for signal in line[0:-4]]
        data = line[-4:]

        for signal in [s for s in preamble if len(s) in [2, 3, 4, 7]]:
            bitmask = signal_to_bitmask(signal)
            num = 0
            if len(signal) == 2:
                num = 1
            if len(signal) == 3:
                num = 7
            if len(signal) == 4:
                num = 4
            if len(signal) == 7:
                num = 8
            patterns[num] = bitmask
            signal_map[signal] = num

        bit13 = patterns[1] ^ patterns[4]

        for signal in [s for s in preamble if len(s) == 5]:
            bitmask = signal_to_bitmask(signal)
            num = 0
            if patterns[1] & bitmask == patterns[1]:
                num = 3
            elif (bit13 & bitmask) == bit13:
                num = 5
            else:
                num = 2
            patterns[num] = bitmask
            signal_map[signal] = num

        for signal in [s for s in preamble if len(s) == 6]:
            bitmask = signal_to_bitmask(signal)
            if not(patterns[1] & bitmask == patterns[1]):
                num = 6
            elif (bit13 & bitmask) == bit13:
                num = 9
            else:
                num = 0
            patterns[num] = bitmask
            signal_map[signal] = num

        number = int("".join([str(signal_map["".join(sorted(signal))]) for signal in data]))
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