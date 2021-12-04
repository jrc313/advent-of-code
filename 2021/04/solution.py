import os
import argparse
from functools import reduce

class Board:
    def __init__(self):
        self.nums = []
        self.w = 0

    def addRow(self, row):
        row = [int(n) for n in row.split()]
        self.w = len(row)
        self.nums += row

    def hasBingo(self, calls):
        if self.testH(calls): return True
        if self.testV(calls): return True
        return False

    def testH(self, calls):
        for i in range(self.w):
            if self.testLine([n for n in self.nums[i * self.w: i * self.w + self.w]], calls):
                return True
        return False

    def testV(self, calls):
        for i in range(self.w):
            if self.testLine([n for n in self.nums[i::self.w]], calls):
                return True
        return False

    def testLine(self, line, calls):
        matches = reduce(lambda acc, n: acc + int(n in calls), line, 0)
        if matches == self.w:
            return True
        return False

    def printBoard(self):
        print(f"{self.nums}")

    def getNonMatches(self, calls):
        return list(set(self.nums) - set(calls))

def makeBoards(boardData):
    board = Board()
    for line in boardData:
        if not(line):
            yield board
            board = Board()
        board.addRow(line)
    yield board

# Part 1
def solve1(input):
    calls = [int(n) for n in input[0].split(",")]
    boards = list(makeBoards(input[2:]))

    for i in range(len(calls)):
        for board in boards:
            if board.hasBingo(calls[0:i]):
                non = board.getNonMatches(calls[0:i])
                return sum(non) * calls[i - 1]

    return "No Win!"

# Part 2
def solve2(input):
    calls = [int(n) for n in input[0].split(",")]
    boards = list(makeBoards(input[2:]))

    wins = []

    for i in range(len(calls)):
        print(f"calling {calls}")
        for board in boards:
            if board.hasBingo(calls[0:i]):
                non = board.getNonMatches(calls[0:i])
                wins.append(sum(non) * calls[i - 1])
                boards.remove(board)

    return wins[len(wins) - 1]

# Testing, testing
def test():
    input = """7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7""".splitlines()
    return solve1(input)


def get_input(filename = "input.txt"):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    input = []
    with open(input_path, "r") as file:
        for line in file:
            input.append(line.rstrip())

    return input


parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

input = get_input()

if args.test:
    print(f"Test: {test()}")
else:
    print(f"Part 1: {solve1(input)}")
    print(f"Part 2: {solve2(input)}")