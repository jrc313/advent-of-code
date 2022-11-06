import os
import argparse
from functools import wraps, reduce
from time import perf_counter

algo = []

def timer(func):
    @wraps(func)
    def wrapper_timer(*args, **kwargs):
        s_time = perf_counter()
        result = func(*args, **kwargs)
        e_time = perf_counter()
        r_time = (e_time - s_time) * 1000
        print(f"func {func.__name__!r} ran in {r_time:.3f}ms")
        return result
    return wrapper_timer

def parse_input(input):
    image = [[]]
    table = {".": 0, "#": 1}
    current = algo
    is_image = False
    for line in input:
        if not line:
            current = image[0]
            is_image = True
            continue
        for c in line: current.append(table[c])
        if is_image:
            current = []
            image.append(current)

    return image[:-1]

def pad_matrix(m, d = 1, val = 0):
    w = len(m)
    vpad = [val] * (d * 2 + w)
    hpad = [val] * d
    return [vpad] * d + [hpad + l + hpad for l in m] + [vpad] * d

def bitlist_to_int(bitlist):
    return reduce(lambda i, e: i + (int(e[1]) << int(e[0])), enumerate(reversed(bitlist)), 0)

def get_matrix_value(m, x, y, iteration):
    if y >= len(m) or x >= len(m[0]) or y < 0 or x < 0:
        if algo[0] == 1: return 1 - iteration % 2
        return 0
    return m[y][x]

def get_pixel_algo_pos(img, x, y, iteration):
    pos = [get_matrix_value(img, x - 1, y - 1, iteration),
           get_matrix_value(img, x, y - 1, iteration),
           get_matrix_value(img, x + 1, y - 1, iteration),
           get_matrix_value(img, x - 1, y, iteration),
           get_matrix_value(img, x, y, iteration),
           get_matrix_value(img, x + 1, y, iteration),
           get_matrix_value(img, x - 1, y + 1, iteration),
           get_matrix_value(img, x, y + 1, iteration),
           get_matrix_value(img, x + 1, y + 1, iteration)]

    return bitlist_to_int(pos)

def enhance_image(img, iteration):
    w = len(img[0])
    h = len(img)
    enhanced = [[0 for _ in range(w + 2)] for _ in range(h + 2)]
    for y in range(-1, h + 1):
        for x in range(-1, w + 1):
            pos = get_pixel_algo_pos(img, x, y, iteration)
            new_val = algo[pos]
            enhanced[y + 1][x + 1] = new_val

    return enhanced

def print_image(img):
    w = len(img[0])
    h = len(img)
    for y in range(h):
        for x in range(w):
            print({0: "⬜️", 1: "🎅"}[img[y][x]], end = "")
        print()
    print()

def enhance_times(img, times):
    for i in range(times):
        img = enhance_image(img, i + 1)

    return img

# Part 1
@timer
def solve1(input):
    img = parse_input(input)
    img = enhance_times(img, 2)
    return sum([sum(row) for row in img])

# Part 2
@timer
def solve2(input):
    img = parse_input(input)
    img = enhance_times(img, 50)
    return sum([sum(row) for row in img])



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