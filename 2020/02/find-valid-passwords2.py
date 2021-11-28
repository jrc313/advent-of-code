import re

pattern = re.compile(r'^([0-9]+)\-([0-9]+) ([a-z]+): ([a-z]+)$')

class Password(object):
  def __init__(self, line):
    matches = pattern.findall(line)
    if len(matches) == 1:
      self.min = int(matches[0][0])
      self.max = int(matches[0][1])
      self.char = matches[0][2]
      self.password = matches[0][3]

  def is_valid(self):
    char1 = self.password[self.min - 1]
    char2 = self.password[self.max - 1]
    return not(char1 == char2) and (char1 == self.char or char2 == self.char)

passwords = []

valid = 0

with open ("passwords.txt") as password_file:
  for line in password_file:
    line = line.rstrip()
    password = Password(line)
    if password.is_valid():
      print(f"{line} is valid")
      valid = valid + 1

print(f"{valid} valid passwords")