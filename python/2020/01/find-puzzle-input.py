expenses = []
with open ("expense-report.txt") as expense_report_file:
  for line in expense_report_file:
    expenses.append(int(line.rstrip()))



i = 0
j = 0
k = 0
for expense1 in expenses:
  for expense2 in expenses:
    for expense3 in expenses:
      if (not(i == j or i == k or j == k) and expense1 + expense2 + expense3 == 2020):
        puzzle_input = expense1 * expense2 * expense3
        print(f"{expense1} + {expense2} + {expense3} = 2020. Puzzle input is {puzzle_input}")
        k = k + 1
      j = j + 1
    i = i + 1