module Aoc202201

    const YEAR::Int = 2022
    const DAY::Int = 1

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function solve()
        return solve(false)
    end

    function solve(test::Bool)
        calories = parseInput(test)
        partialsort!(calories, 1:3, rev = true)
        part1 = calories[1]
        part2 = calories[1:3] |> sum

        return (part1, part2)
    end

    function parseInput(test::Bool)
        inputFile::String = AocUtils.getInputFilename(YEAR, DAY, test)

        calories::Vector{Int} = Vector{Int}[]
        calorieTally::Int = 0

        for line in eachline(inputFile)
            if isempty(line)
                push!(calories, calorieTally)
                calorieTally = 0
            else
                calorieTally += parse(Int, line)
            end
        end

        return calories
    end

end