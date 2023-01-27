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
elif [ "${LANG}" = "julia" ]
then
    LANG_EXT="jl"
else
    printf "Unknown language %s\n" $LANG >&2
    exit 1
fi

DAY_TEMPLATE="./${LANG}/day_template.${LANG_EXT}"

DAY_0=$(printf "%02d" "${DAY}")
LANGDIR="./${LANG}"
YEARDIR="./${LANG}/${YEAR}"
DAYDIR="./${LANG}/${YEAR}/${DAY_0}"
SOLUTION_FILE="${DAYDIR}/solution.${LANG_EXT}"
SESSION=$(<.env)
PUZZLE_URL="https://adventofcode.com/${YEAR}/day/${DAY}"
INPUT_URL="${PUZZLE_URL}/input"
INPUT_FILE="${DAYDIR}/input.txt"
TEST_FILE="${DAYDIR}/test.txt"

[ ! -d "${LANGDIR}" ] && mkdir "${LANGDIR}"
[ ! -d "${YEARDIR}" ] && mkdir "${YEARDIR}"
[ ! -d "${DAYDIR}" ] && mkdir "${DAYDIR}"
[ ! -f "${DAY_TEMPLATE}" ] && touch "${DAY_TEMPLATE}"
[ ! -f "${SOLUTION_FILE}" ] && cp "${DAY_TEMPLATE}" "${SOLUTION_FILE}"
[ ! -f "${TEST_FILE}" ] && touch "${TEST_FILE}"
[ ! -f "${INPUT_FILE}" ] && curl -H "Cookie: ${SESSION}" "${INPUT_URL}" --output "${INPUT_FILE}"

sed -i "" "s/%Y/${YEAR}/g" "${SOLUTION_FILE}"
sed -i "" "s/%D0/${DAY_0}/g" "${SOLUTION_FILE}"
sed -i "" "s/%D/${DAY}/g" "${SOLUTION_FILE}"

code ${SOLUTION_FILE}
Open "${PUZZLE_URL}"