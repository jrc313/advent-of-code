terrain = []
OPEN = "."
TREE = "#"

def hit_the_slope(terrain, right, down):
  position = 0
  trees = 0
  path = ""

  for i in range(0, len(terrain), down):
    line = terrain[i]
    normalised_position = position % terrain_width
    char_at_position = line[normalised_position]
    if char_at_position == TREE:
      trees += 1
    path += char_at_position
    position += right

  return trees


with open ("input.txt") as input_file:
  for line in input_file:
    terrain.append(line.rstrip())

terrain_height = len(terrain) 
terrain_width = len(terrain[0])

print(f"Terrain: {terrain_width}x{terrain_height}")


path1 = hit_the_slope(terrain, 1, 1)
path2 = hit_the_slope(terrain, 3, 1)
path3 = hit_the_slope(terrain, 5, 1)
path4 = hit_the_slope(terrain, 7, 1)
path5 = hit_the_slope(terrain, 1, 2)

answer = path1 * path2 * path3 * path4 * path5

print(f"{path1}*{path2}*{path3}*{path4}*{path5} = {answer}")