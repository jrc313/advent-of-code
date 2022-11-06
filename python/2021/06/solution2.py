import os
import argparse
from functools import reduce

input_file = os.path.dirname(os.path.realpath(__file__)) + f"/input.txt"
input = [line.rstrip() for line in open(input_file)][0]
school = reduce(lambda acc, i: acc[i] += 1, [input[0] for i in range(0, len(input), 2)], [0] * 9)

print(school)