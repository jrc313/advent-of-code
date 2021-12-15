import os
import argparse
import heapq, math
from collections import defaultdict

def get_neighbours(xy, end):
    x, y = xy
    ex, ey = end
    n = []
    if x + 1 <= ex: n += [(x + 1, y)]
    if y + 1 <= ey: n += [(x, y + 1)]
    if x > 0: n += [(x - 1, y)]
    if y > 0: n += [(x, y - 1)]

    return n


def get_grid_value(grid, xy):
    x, y = xy
    w = len(grid[0])
    h = len(grid)

    xpos = x % w
    ypos = y % h

    xmul = math.floor(x / w)
    ymul = math.floor(y / h)

    v = (grid[ypos][xpos] + xmul + ymul - 1) % 9 + 1
    return v


def dijkstra(grid, start, end):
    distances = defaultdict(lambda: math.inf)
    distances[start] = 0
    q = []
    heapq.heappush(q, (0, start))

    while len(q) > 0:
        current_dist, current = heapq.heappop(q)
        if current_dist > distances[current]:
            continue

        for neighbour in get_neighbours(current, end):
            neighbour_dist = get_grid_value(grid, neighbour) + current_dist

            if neighbour_dist < distances[neighbour]:
                distances[neighbour] = neighbour_dist
                heapq.heappush(q, (neighbour_dist, neighbour))

    return distances


# Part 1
def solve1(input):
    w = len(input[0])
    h = len(input)

    end = (w - 1, h - 1)
    return dijkstra(input, (0, 0), (w - 1, h - 1))[end]

# Part 2
def solve2(input):
    w = len(input[0]) * 5
    h = len(input) * 5

    end = (w - 1, h - 1)
    return dijkstra(input, (0, 0), (w - 1, h - 1))[end]


def get_input(filename):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    return [[int(c) for c in line.rstrip()] for line in open(input_path)]

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

filename = "input.txt"
if args.test:
    filename = "test.txt"

input = get_input(filename)

print(f"Part 1: {solve1(input)}")
print(f"Part 2: {solve2(input)}")