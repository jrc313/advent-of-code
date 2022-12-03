#!/bin/bash

LANG="$1"
YEAR="$2"
DAY="$3"

if [ "${LANG}" = "python" ]
then
    LANG_EXT="py"
elif [ "${LANG}" = "racket" ]
then
    LANG_EXT="rkt"
else
    printf "Unknown language %s\n" $LANG >&2
    exit 1
fi

DAY_TEMPLATE="./${LANG}/day_template.${LANG_EXT}"

DAY_0=$(printf "%02d" "${DAY}")
BASEDIR="./${LANG}/${YEAR}/${DAY_0}"
SOLUTION_FILE="${BASEDIR}/solution.${LANG_EXT}"
SESSION=$(<.env)
PUZZLE_URL="https://adventofcode.com/${YEAR}/day/${DAY}"
INPUT_URL="${PUZZLE_URL}/input"
INPUT_FILE="${BASEDIR}/input.txt"
TEST_FILE="${BASEDIR}/test.txt"

[ ! -d "${BASEDIR}" ] && mkdir "${BASEDIR}"
[ ! -f "${SOLUTION_FILE}" ] && cp "${DAY_TEMPLATE}" "${SOLUTION_FILE}"
[ ! -f "${TEST_FILE}" ] && touch "${TEST_FILE}"
[ ! -f "${INPUT_FILE}" ] && curl -H "Cookie: ${SESSION}" "${INPUT_URL}" --output "${INPUT_FILE}"

code ${SOLUTION_FILE}
Open "${PUZZLE_URL}"