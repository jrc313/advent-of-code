module Aoc202501

    const YEAR::Int = 2025
    const DAY::Int = 1

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

        pos = 50
        zeros = 0
        extrazeros = 0

        actions = Dict('R' => +, 'L' => -)

        for line in input
            dir = line[1]
            num = parse(Int, line[2:end])

            startzero = pos == 0

            pos = actions[dir](pos, num)
            turns = abs(pos) ÷ 100

            negativepos = pos < 0

            if pos > 99 || pos < 0
                pos = mod(pos, 100)
                if !startzero && negativepos
                    turns += 1
                end
                if pos == 0
                    turns -= 1
                end
            end

            extrazeros += turns

            if pos == 0
                zeros += 1
            end

        end

        part1 = zeros
        part2 = zeros + extrazeros

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinputlines(YEAR, DAY, test)
    end

end