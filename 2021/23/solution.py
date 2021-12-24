import os
import argparse
from functools import lru_cache, wraps, reduce
from time import perf_counter
import math

CHAR_ROOM = {"A": 1, "B": 2, "C": 3, "D": 4}
ROOM_CHAR = {1: "A", 2: "B", 3: "C", 4: "D"}
CHAR_COST = {"A": 1, "B": 10, "C": 100, "D": 1000}
EMPTY_SPACE = "."

def timer(func):
    @wraps(func)
    def wrapper_timer(*args, **kwargs):
        s_time = perf_counter()
        result = func(*args, **kwargs)
        e_time = perf_counter()
        r_time = e_time - s_time
        print(f"func {func.__name__!r} ran in {r_time:.5f}s")
        return result
    return wrapper_timer


def print_board(board):
    print(board[0])
    for i in reversed(range(0, len(board[1]))):
        print("  ", end = "")
        for room in range(1, 5):
            print(board[room][i], end = " ")
        print()
    print()

@lru_cache(maxsize = None)
def is_winning_board(board):
    return (board[1] == "A" * len(board[1]) and
            board[2] == "B" * len(board[2]) and
            board[3] == "C" * len(board[3]) and
            board[4] == "D" * len(board[4]))

@lru_cache(maxsize = None)
def valid_hallway_position(pos):
    return pos < 2 or pos > 9 or pos % 2 == 1

@lru_cache(maxsize = None)
def is_over_room(pos):
    if valid_hallway_position(pos): return 0
    return (pos // 2) % 5

@lru_cache(maxsize = None)
def room_has_only_valid_occupants(board, room):
    char = ROOM_CHAR[room]
    for c in board[room]:
        if not c in [char, EMPTY_SPACE]: return False
    return True

@lru_cache(maxsize = None)
def can_enter_room(char, board, room):
    if not room == CHAR_ROOM[char]: return False
    return room_has_only_valid_occupants(board, room)

@lru_cache(maxsize = None)
def get_valid_moves_in_dir(char, pos, board, direction):
    valid_moves = []
    came_from_room = is_over_room(pos) > 0
    hall = board[0]
    pos += direction
    while pos >= 0 and pos < len(hall):
        if not hall[pos] == EMPTY_SPACE: break
        room = is_over_room(pos)
        if can_enter_room(char, board, room): return room, []
        if valid_hallway_position(pos) and came_from_room: valid_moves += [pos]
        pos += direction

    return 0, valid_moves

@lru_cache(maxsize = None)
def get_valid_moves(char, pos, board):
    # left moves
    valid_room, left_moves = get_valid_moves_in_dir(char, pos, board, -1)
    if valid_room: return valid_room, []
    # right moves
    valid_room, right_moves = get_valid_moves_in_dir(char, pos, board, 1)
    return valid_room, left_moves + right_moves

@lru_cache(maxsize = None)
def get_chars_in_hall(board):
    chars = []
    for i, char in enumerate(board[0]):
        if not char == EMPTY_SPACE: chars += [(i, char)]

    return chars

@lru_cache(maxsize = None)
def get_next_in_room(board, room):
    if room_has_only_valid_occupants(board, room): return False
    return board[room][get_last_char_pos_in_room(board, room)]

@lru_cache(maxsize = None)
def get_last_char_pos_in_room(board, room):
    for i in reversed(range(0, len(board[room]))):
        if not board[room][i] == EMPTY_SPACE: return i
    return -1

def count_chars_in_room(board, room):
    return reduce(lambda acc, c: acc + int(not c == EMPTY_SPACE), board[room], 0)

@lru_cache(maxsize = None)
def replace_char_in_str(s, i, c):
    l = list(s)
    l[i] = c
    return "".join(l)

@lru_cache(maxsize = None)
def move_piece(board, start_room, start, end_room, end):
    cost = 0
    new_board = list(board)
    room_len = len(board[1])

    char = new_board[0][start]
    if start_room:
        last_char_pos = count_chars_in_room(board, start_room) - 1
        cost += room_len - last_char_pos
        char = new_board[start_room][last_char_pos]
        new_board[start_room] = replace_char_in_str(new_board[start_room], last_char_pos, EMPTY_SPACE)
        start = start_room * 2
    else: new_board[0] = replace_char_in_str(new_board[0], start, EMPTY_SPACE)

    if end_room:
        new_char_pos = count_chars_in_room(board, end_room)
        cost += room_len - new_char_pos
        end = end_room * 2
        new_board[end_room] = replace_char_in_str(new_board[end_room], new_char_pos, char)
    else: new_board[0] = replace_char_in_str(new_board[0], end, char)

    board = tuple(new_board)

    cost += abs(start - end)
    return cost * CHAR_COST[char], board

@lru_cache(maxsize = None)
def run_board(board, cost:int):
    if is_winning_board(board):
        return cost

    costs = []

    is_stalemate = True

    # Try to move from room
    for room in range(1, 5):
        char = get_next_in_room(board, room)
        if char:
            new_room, valid_moves = get_valid_moves(char, room * 2, board)
            # Can move to a room
            if new_room:
                is_stalemate = False
                new_cost, new_board = move_piece(board, room, 0, new_room, 0)
                costs.append(run_board(new_board, cost + new_cost))

            # Otherwise try other moves
            elif len(valid_moves):
                is_stalemate = False
                for move in valid_moves:
                    new_cost, new_board = move_piece(board, room, 0, 0, move)
                    costs.append(run_board(new_board, cost + new_cost))

    # Move chars in hallway
    for pos, char in get_chars_in_hall(board):
        new_room, valid_moves = get_valid_moves(char, pos, board)
        if new_room:
            is_stalemate = False
            new_cost, new_board = move_piece(board, 0, pos, new_room, 0)
            costs.append(run_board(new_board, cost + new_cost))

        elif len(valid_moves):
            is_stalemate = False
            for move in valid_moves:
                new_cost, new_board = move_piece(board, 0, pos, 0, move)
                costs.append(run_board(new_board, cost + new_cost))

    if is_stalemate:
        return math.inf

    return min(costs)

# Part 1
@timer
def solve1(input):
    board = ("...........", "CD", "CB", "DB", "AA")
    return run_board(board, 0)


# Part 2
@timer
def solve2(input):
    board = ("...........", "CDDD", "CBCB", "DABB", "ACAA")
    return run_board(board, 0)



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