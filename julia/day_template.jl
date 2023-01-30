module Aoc%Y%D0

    const YEAR::Int = %Y
    const DAY::Int = %D

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function test()
        return solve(true)
    end

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