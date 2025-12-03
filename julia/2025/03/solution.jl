module Aoc202503

    const YEAR::Int = 2025
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

    function findlargestinstring(s)
        topi = 0
        topc = ' '
        for (i, c) in enumerate(s)
            if c > topc
                topi = i
                topc = c
                topc == '9' && break
            end
        end
        return (topi, topc)
    end

    function findlargestjoltage(battery, size)
        joltage = ""
        bank = 0

        for i in 1:size
            (nextbank, rating) = findlargestinstring(battery[bank + 1:end - (size - i)])
            bank += nextbank
            joltage *= rating
        end
        return parse(Int, joltage)
    end

    function solve(test::Bool)
        part1 = 0
        part2 = 0

        for line in AocUtils.eachinputlines(YEAR, DAY, test)
            part1 += findlargestjoltage(line, 2)
            part2 += findlargestjoltage(line, 12)
        end

        return (part1, part2)
    end
    
end