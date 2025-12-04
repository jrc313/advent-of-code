module Aoc202504

    const YEAR::Int = 2025
    const DAY::Int = 4

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
        dims = size(input)

        part1 = 0
        part2 = 0

        for c in CartesianIndices(input)
            !input[c] && continue
            length(filter(p -> input[p], getadjacents(c, dims))) < 4 && (part1 += 1)
        end

        totalrolls = count(input)
        hasremoved = true
        while hasremoved
            hasremoved = false
            for c in CartesianIndices(input)
                !input[c] && continue
                rollcount = length(filter(p -> input[p], getadjacents(c, dims)))
                if rollcount < 4
                    input[c] = false
                    hasremoved = true
                end
            end

        end

        part2 = totalrolls - count(input)

        return (part1, part2)
    end

    function parseinput(test::Bool)::Matrix{Bool}
        return AocUtils.loadmatrix(YEAR, DAY, test, (c, pos) -> c == '@')
    end

end