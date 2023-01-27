module Aoc202202

    const YEAR::Int = 2022
    const DAY::Int = 2

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        input = parseInput(test)

        part1 = 0
        part2 = 0

        return (part1, part2)
    end

    function parseInput(test::Bool)
        return AocUtils.getInput(YEAR, DAY, test)
    end

end