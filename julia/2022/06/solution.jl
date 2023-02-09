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

        input = parseinput(test)

        part1 = findmarker(input, 4)
        part2 = findmarker(input, 14, part1)

        return (part1, part2)
    end

    function nextoffset(s::AbstractString)
        chars = Base.Set{Char}(s[1])
        for c in s[2:end]
            if c in chars
                return findfirst(c, s)
            end
            push!(chars, c)
        end

        return 0
    end

    function findmarker(signal::AbstractString, size::Int, start::Int = 1)
        pos = start
        len = length(signal)
        while pos < len - 1
            offset = nextoffset(signal[pos:pos + size - 1])
            if offset === 0
                return pos + size - 1
            end
            pos += offset
        end

        return 0
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end