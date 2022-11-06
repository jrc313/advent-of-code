import os
from functools import reduce
from PIL import Image, ImageDraw

def split_coord(coord_s):
    coord = coord_s.split(",")
    return [int(coord[0]), int(coord[1])]

def get_coords(input):
    pairs = [line.split(" -> ") for line in input]
    return [[split_coord(coords[0]), split_coord(coords[1])] for coords in pairs]

def get_dir(a, b):
    if a == b: return 0
    return int((b - a) / abs(b - a))

def get_key(p):
    return f"{p[0]},{p[1]}"

def expand_line(p1, p2):
    p = [p1[0], p1[1]]
    xdir = get_dir(p1[0], p2[0])
    ydir = get_dir(p1[1], p2[1])
    yield get_key(p)
    while not(p[0] == p2[0] and p[1] == p2[1]):
        p[0] += xdir
        p[1] += ydir
        yield get_key(p)

def get_points(coords):
    points = {}
    for pair in coords:
        for p in expand_line(pair[0], pair[1]):
            points[p] = points.get(p, 0) + 1

    return points

def get_dimensions(coords):
    max_x = 0
    max_y = 0
    for pair in coords:
        max_x = max(max_x, pair[0][0], pair[1][0])
        max_y = max(max_y, pair[0][1], pair[1][1])
    return [max_x, max_y]

def get_max_visits(points):
    return reduce(max, points.values())

def get_brightness(b_mul, b_min, visits):
    return int((b_mul * visits) + b_min)

def draw(coords, border, bgcolor, h, s_min, b_min):
    points = get_points(coords)
    dimensions = get_dimensions(coords)
    dimensions[0] += border * 2
    dimensions[1] += border * 2
    max_visits = get_max_visits(points)

    b_mul = (255 - b_min) / max_visits
    s_mul = (255 - s_min) / max_visits
 
    image = Image.new("HSV", dimensions, bgcolor)
    draw = ImageDraw.Draw(image)

    for point in points:
        coord = point.split(",")
        b = get_brightness(b_mul, b_min, points[point])
        s = get_brightness(s_mul, s_min, points[point])
        draw.point((int(coord[0]) + border, int(coord[1]) + border), (h, s, b))

    image = image.convert("RGB")
    image.save(os.path.dirname(os.path.realpath(__file__)) + "/out.png")


def get_input(filename):
    input_path = os.path.dirname(os.path.realpath(__file__)) + f"/{filename}"
    return [line.rstrip() for line in open(input_path)]

input = get_input("input.txt")
coords = get_coords(input)
draw(coords, 50, (0, 0, 0), 120, 100, 10)

