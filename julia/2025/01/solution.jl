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

        pos = 50
        zeros = 0

        startzero = false
        negativepos = false
        turns = 0

        for line in AocUtils.eachinputlines(YEAR, DAY, test)

            startzero = pos == 0

            dir = line[1]
            num = parse(Int, line[2:end])

            pos = dir == 'R' ? pos + num : pos - num

            if pos > 99 || pos < 0
                turns += abs(pos) ÷ 100
                negativepos = pos < 0
                pos = mod(pos, 100)
                !startzero && negativepos && (turns += 1)
                pos == 0 && (turns -= 1)
            end

            pos == 0 && (zeros += 1)

        end

        return (zeros, zeros + turns)
    end

    function parseinput(test::Bool)
        return AocUtils.getinputlines(YEAR, DAY, test)
    end

end