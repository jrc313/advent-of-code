import os
import argparse
from functools import reduce

def test_line(line, calls):
    return reduce(lambda acc, n: acc + int(n in calls), line, 0) == len(line)

def board_has_bingo(board, calls, w):
    for i in range(w):
        if test_line([n for n in board[i * w: i * w + w]], calls): return True
        if test_line([n for n in board[i::w]], calls): return True
    return False

def makeBoards(boardData):
    board = []
    for line in boardData:
        if not(line):
            yield board
            board = []
        board += [int(n) for n in line.split()]
    yield board

def solve(input):
    calls = [int(n) for n in input[0].split(",")]
    boards = list(makeBoards(input[2:]))
    w = len(input[2].split())

    wins = []

    for i in range(w, len(calls)):
        for board in boards:
            if board_has_bingo(board, calls[0:i], w):
                wins.append(sum(list(set(board) - set(calls[0:i])) * calls[i - 1]))
                boards.remove(board)
    
    return f"Part 1: {wins[0]}, Part 2: {wins[-1]}"

# Testing, testing
def test():
    return ""


def get_input(filename = "input.txt"):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    return [line.rstrip() for line in open(input_path)]


parser = argparse.ArgumentParser()
parser.add_argument("-t", "--test", action = "store_true")
args = parser.parse_args()

input = get_input()

if args.test:
    print(f"Test: {test()}")
else:
    print(f"{solve(input)}")