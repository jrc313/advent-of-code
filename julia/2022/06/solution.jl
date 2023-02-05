module Aoc202206

    const YEAR::Int = 2022
    const DAY::Int = 6

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

        part1 = findmarker(input, 4)
        part2 = findmarker(input, 14, part1)

        return (part1, part2)
    end

    function isdistinct(s::AbstractString)
        chars = Base.Set{Char}(s[1])
        for c in s[2:end]
            if c in chars
                return false
            end
            push!(chars, c)
        end

        return true
    end

    function findmarker(signal::AbstractString, size::Int, start::Int = 1)
        for (pos, marker) in enumerate(Iterators.map(i -> signal[i:i + size - 1], start:(length(signal) - size)))
            if isdistinct(marker)
                return pos + size + start - 2
            end
        end

        return 0
    end

    function parseInput(test::Bool)
        return AocUtils.getInput(YEAR, DAY, test)
    end

end