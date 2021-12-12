import os
import argparse
from collections import defaultdict, deque
from functools import reduce

class Graph:
    def __init__(self):
        self.path_count = 0
        self.paths = []
        self.little_caves = set()
        self.graph = defaultdict(list)

    def addEdge(self, a, b):
        self.__addEdge(a, b)
        self.__addEdge(b, a)

    def __addEdge(self, a, b):
        if (a == "end"): return
        if (b == "start"): return
        self.graph[a].append(b)
        if a.lower() == a and a not in ["start", "end"]: self.little_caves.add(a)

    def doSearch(self, a, target, visited = set(), current_path = deque(), allow_two = ""):
        
        current_path.append(a)
        visit_count = count_instances(current_path, a)
        if a.lower() == a and (not(a == allow_two) or visit_count >= 2):
            visited.add(a)

        if a == target:
            self.paths.append(",".join(current_path))
            self.path_count += 1

        else:
            for b in self.graph[a]:
                if b not in visited:
                    self.doSearch(b, target, visited, current_path, allow_two)

        current_path.remove(a)
        visited.discard(a)

    def search(self, start, target, allow_two):
        self.paths.clear()
        self.path_count = 0
        self.doSearch(start, target, allow_two = allow_two)
        return self.path_count

def count_instances(q, a):
    return len(list(filter(lambda n: a == n, q)))

def build_graph(input):
    g = Graph()
    for line in input:
        (a, b) = line.split("-")
        g.addEdge(a, b)

    return g

# Part 1
def solve1(g):
    total = g.search("start", "end", "")
    return total

# Part 2
def solve2(g):
    original_total = g.path_count
    return reduce(lambda acc, i: acc + (i - original_total),
        [g.search("start", "end", a) for a in g.little_caves], original_total)


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
g = build_graph(input)

print(f"Part 1: {solve1(g)}")
print(f"Part 2: {solve2(g)}")