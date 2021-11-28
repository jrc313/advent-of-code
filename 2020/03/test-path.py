terrain = []
OPEN = "."
TREE = "#"


with open ("input.txt") as input_file:
  for line in input_file:
    terrain.append(line.rstrip())

terrain_height = len(terrain) 
terrain_width = len(terrain[0])

print(f"Terrain: {terrain_width}x{terrain_height}")

position = 0
trees = 0
path = ""

for line in terrain:
  normalised_position = position % terrain_width
  char_at_position = line[normalised_position]
  if char_at_position == TREE:
    trees += 1
  path += char_at_position
  position += 3

print(f"Hit {trees} trees")
print(f"{path}")