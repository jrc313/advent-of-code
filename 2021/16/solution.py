import os
import argparse
from functools import reduce
from math import prod

versions = []
transmission = ""
operations = {
    0: lambda nums: sum(nums),
    1: lambda nums: prod(nums),
    2: lambda nums: min(nums),
    3: lambda nums: max(nums),
    5: lambda nums: int(nums[0] > nums[1]),
    6: lambda nums: int(nums[0] < nums[1]),
    7: lambda nums: int(nums[0] == nums[1])
}

def bitlist_to_int(bitlist):
    return reduce(lambda i, e: i + (int(e[1]) << int(e[0])), enumerate(reversed(bitlist)), 0)

def char_to_bin(char):
    hex_str = f"0x{char}"
    num = int(hex_str, 16)
    bits = len(char) * 4
    return f"{num:0>{bits}b}"


def parse_transmission(trans_h):
    return char_to_bin(trans_h)


def parse_packet(head):
    version = bitlist_to_int(transmission[head : head + 3])
    type = bitlist_to_int(transmission[head + 3 : head + 6])
    versions.append(version)
    head += 6

    if type == 4:
        return parse_literal(head)

    return parse_operator(type, head)


def parse_literal(head):
    literal_b = ""
    while head < len(transmission):
        first_b = transmission[head]
        literal_b += transmission[head + 1 : head + 5]
        head += 5
        if first_b == "0":
            return bitlist_to_int(literal_b), head

    return 0

def parse_operator(type, head):
    nums = []
    
    len_type = transmission[head]
    head += 1

    len_size = {"0": 15, "1": 11}[len_type]
    sub_packet_len = bitlist_to_int(transmission[head : head + len_size])
    head += len_size

    if len_type == "0":
        max_pos = head + sub_packet_len
        while head < max_pos:
            result, head = parse_packet(head)
            nums.append(result)

    else:
        for n in range(0, sub_packet_len):
            result, head = parse_packet(head)
            nums.append(result)

    result = operations[type](nums)
    return result, head


# Part 1
def solve1(input):
    parse_packet(0)
    return sum(versions)

# Part 2
def solve2(input):
    result, i = parse_packet(0)
    return result



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
transmission = parse_transmission(input[0])

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")