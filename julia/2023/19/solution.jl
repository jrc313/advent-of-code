module Aoc202319

    const YEAR::Int = 2023
    const DAY::Int = 19

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        input = parseinput(test)

        part1 = 0
        part2 = 0

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end