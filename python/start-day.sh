#!/bin/bash

DAY_TEMPLATE="day_template.py"
YEAR="$1"
DAY="$2"
DAY_0=$(printf "%02d" $2)
BASEDIR="./${YEAR}/${DAY_0}"
SOLUTION_FILE="${BASEDIR}/solution.py"
SESSION=$(<.env)
PUZZLE_URL="https://adventofcode.com/${YEAR}/day/${DAY}"
INPUT_URL="${PUZZLE_URL}/input"
INPUT_FILE="${BASEDIR}/input.txt"
TEST_FILE="${BASEDIR}/test.txt"

[ ! -d "${BASEDIR}" ] && mkdir "${BASEDIR}"
[ ! -f "${SOLUTION_FILE}" ] && cp "${DAY_TEMPLATE}" "${SOLUTION_FILE}"
[ ! -f "${TEST_FILE}" ] && touch "${TEST_FILE}"
[ ! -f "${INPUT_FILE}" ] && curl -H "Cookie: ${SESSION}" "${INPUT_URL}" --output "${INPUT_FILE}"
Open "${PUZZLE_URL}"