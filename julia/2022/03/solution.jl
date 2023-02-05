module Aoc202203

    const YEAR::Int = 2022
    const DAY::Int = 3

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function charToScore(c::Char)
        return c > 'Z' ? Int(c) - 96 : Int(c) - 38
    end

    function solve(test::Bool)

        lines::Vector{AbstractString} = parseInput(test)
        
        part1::Int = [charToScore(first(∩(line[1:end ÷ 2], line[end ÷ 2 + 1:end]))) for line in lines] |> sum
        part2::Int = [charToScore(first(∩(group...))) for group in Iterators.partition(lines, 3)] |> sum

        return (part1, part2)
    end

    function parseInput(test::Bool)
        filename::String = AocUtils.getInputFilename(YEAR, DAY, test)
        return readlines(filename)
    end

end