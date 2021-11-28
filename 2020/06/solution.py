import os
import argparse


# Part 1
def solve1(input):
    groups = [""]
    group_number = 0

    for line in input:
        if not(line):
            group_number += 1
            groups.append("")
            continue
        for char in line:
            if not(char in groups[group_number]):
                groups[group_number] += char

    sum = 0
    for group in groups:
        sum += len(group)
        print("".join(sorted(group)))

    print(f"Answer: {sum}")



# Part 2
def solve2(input, verbose = False):
    groups = [""]
    group_number = 0
    first_person = True

    for line in input:
        if not(line):
            group_number += 1
            first_person = True
            groups.append("")
            continue
        if first_person:
            groups[group_number] = line
            first_person = False
            continue
        temp = ""
        for char in line:
            if groups[group_number].find(char) > -1:
                temp += char
        groups[group_number] = temp

        if verbose:
            print(f"{group_number}: {groups[group_number]}")

    sum = 0
    for group in groups:
        sum += len(group)
        print("".join(sorted(group)))

    print(f"Answer: {sum}")
    print(f"")

# Testing, testing
def test():
    input = """abc

a
b
c

ab
ac

a
a
a
a

b""".splitlines()
    solve2(input, True)


input_path = os.path.dirname(os.path.realpath(__file__)) + "/input.txt"
input = []
with open(input_path, "r") as file:
    input = file.read().splitlines()

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()
if args.test:
    test()
else:
    solve1(input)
    solve2(input)