module Aoc202403

    const YEAR::Int = 2024
    const DAY::Int = 3

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
        p1re = r"mul\(([0-9]+),([0-9]+)\)"
        
        part1 = sum([reduce(*, (parse.(Int, m.captures)), init = 1) for m in eachmatch(p1re, input)])

        domul = true
        part2 = 0
        p2re = r"mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)"
        for m in eachmatch(p2re, input)
            if m.match == "do()"
                domul = true
            elseif m.match == "don't()"
                domul = false
            elseif domul
                part2 += reduce(*, (parse.(Int, m.captures)), init = 1)
            end
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end