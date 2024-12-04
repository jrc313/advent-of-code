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
        domul = true
        part1 = 0
        part2 = 0
        re = r"mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)"
        for m in eachmatch(re, input)
            if m.match == "do()"
                domul = true
            elseif m.match == "don't()"
                domul = false
            else
                mul = parse(Int, m.captures[1]) * parse(Int, m.captures[2])
                part1 += mul
                if domul
                    part2 += mul
                end
            end
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end