import os
import argparse
from functools import reduce

def test_line(line, calls):
    return reduce(lambda acc, n: acc + int(n in calls), line, 0) == len(line)

def get_h_line(board, i, w):
    return [n for n in board[i * w: i * w + w]]

def get_v_line(board, i, w):
    return [n for n in board[i::w]]

def board_has_bingo(board, calls, w):
    for i in range(w):
        if test_line(get_h_line(board, i, w), calls): return True
        if test_line(get_v_line(board, i, w), calls): return True
    return False

def non_matches(board, calls):
    return list(set(board) - set(calls))

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

    for i in range(len(calls)):
        for board in boards:
            if board_has_bingo(board, calls[0:i], w):
                wins.append(sum(non_matches(board, calls[0:i]) * calls[i - 1]))
                boards.remove(board)
    
    return f"Part 1: {wins[0]}, Part 2: {wins[-1]}"

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
    return solve(input)


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
    print(f"{solve(input)}")