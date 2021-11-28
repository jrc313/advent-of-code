import re
import json
from functools import partial


def test_int(min, max, value):
  return int(value) >= min and int(value) <= max

def test_pattern(pattern, value):
  compiled_pattern = re.compile(pattern)
  return len(compiled_pattern.findall(value)) > 0

def test_one_of(list, value):
  for item in list:
    if item == value:
      return True
  return False

def test_height(value):
  units = value[-2:]
  if units == "cm":
    return test_int(150, 193, value[0:-2])
  if units == "in":
    return test_int(59, 76, value[0:-2])
  return False


required_fields = {"byr": partial(test_int, 1920, 2002),
                   "iyr": partial(test_int, 2010, 2020),
                   "eyr": partial(test_int, 2020, 2030),
                   "hgt": partial(test_height),
                   "hcl": partial(test_pattern, "^#[0-9a-f]{6}$"),
                   "ecl": partial(test_one_of, ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]),
                   "pid": partial(test_pattern, "^[0-9]{9}$")}
required_field_count = len(required_fields)

def test_passport(passport):
  valid_fields = 0
  for field in passport:
    if field in required_fields:
      if required_fields[field](passport[field]):
        valid_fields += 1
  return valid_fields == required_field_count



current_record_fields = {}
valid_passports = 0

with open ("input.txt") as input_file:
  for line in input_file:
    line = line.rstrip()
    if not line:
      print(f"Checking {json.dumps(current_record_fields)}")
      if test_passport(current_record_fields):
        valid_passports += 1
      current_record_fields = {}
    else:
      for item in line.split(" "):
        kvp = item.split(":")
        print(f"Testing {json.dumps(kvp)}")
        if kvp[0] in required_fields:
          current_record_fields[kvp[0]] = kvp[1]

print(f"Checking {json.dumps(current_record_fields)}")
if test_passport(current_record_fields):
  valid_passports += 1

print(f"Found {valid_passports} valid passports")


