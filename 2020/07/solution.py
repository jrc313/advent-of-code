import os
import argparse

def new_bag(colour, baggage):
    if not(colour in baggage):
        baggage[colour] = Node(colour)
    return baggage[colour]

def get_baggage(input):
    input = [line[:-1].split(" bags contain ") for line in input]
    input = [[colour, unpack_bag_contents(bags)] for colour, bags in input]

    baggage = {}

    for colour, contents in input:
        bag = new_bag(colour, baggage)
        for child_colour in contents:
            bag.addChild(new_bag(child_colour, baggage), contents[child_colour])
    
    return baggage

class Edge:
    def __init__(self, parent, child, quantity):
        self.parent = parent
        self.child = child
        self.quantity = quantity
        parent.children[child.colour] = self
        child.parents[parent.colour] = self

    def destroy(self):
        self.parent.children.pop(self.child.colour)
        self.child.parents.pop(self.parent.colour)

class Node:
    def __init__(self, colour):
        self.colour = colour
        self.children = {}
        self.parents = {}

    def addToParent(self, parent, quantity):
        e = Edge(parent, self, quantity)

    def addChild(self, child, quantity):
        e = Edge(self, child, quantity)

    def removeFromParent(self, parent):
        self.parents[parent.colour].destroy()
    
    def removeChild(self, child):
        self.children[child.colour].destroy()

    def findParents(self):
        parents = [parent for parent in self.parents]
        for parent in self.parents:
            parents += self.parents[parent].parent.findParents()
        return set(parents)

    def printChildren(self, depth = 0, quantity = 1):
        print(("  " * depth) + f"{quantity}. {self.colour}")
        for child in self.children:
            edge = self.children[child]
            edge.child.printChildren(depth + 1, edge.quantity)

    def countChildren(self):
        total = 0
        for child in self.children:
            edge = self.children[child]
            child_total = edge.child.countChildren()
            total += edge.quantity + (edge.quantity * child_total)
        return total

# Part 1
def solve1(baggage):
    gold_bag = baggage["shiny gold"]
    parents = gold_bag.findParents()
    
    return len(parents)

# Part 2
def solve2(baggage):
    gold_bag = baggage["shiny gold"]
    return gold_bag.countChildren()

# Testing, testing
def test():
    input = """light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.""".splitlines()
    baggage = get_baggage(input)
    part1 = solve1(baggage)
    part2 = solve2(baggage)

    return f"Part 1: {part1}, Part 2: {part2}"


def get_input(filename = "input.txt"):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    return [line.rstrip() for line in open(input_path)]

def unpack_bag_contents(bags):
    bag_contents = {}
    for bag in bags.split(", "):
        if bag == "no other bags":
            continue
        first_space = bag.find(" ")
        last_space = bag.rfind(" ")
        bag_contents[bag[first_space + 1:last_space]] = int(bag[0:first_space])
    return bag_contents
    

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

input = get_input()

if args.test:
    print(f"Test: {test()}")
else:
    baggage = get_baggage(input)
    print(f"Part 1: {solve1(baggage)}")
    print(f"Part 2: {solve2(baggage)}")