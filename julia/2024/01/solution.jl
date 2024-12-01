module Aoc202401

    const YEAR::Int = 2024
    const DAY::Int = 01

    export solve

    include("../../AocUtils.jl")
    using .AocUtils
    using DataStructures
    using DataFrames

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        input::DataFrame = parseinput(test)
        l1::Vector{Int64} = sort(input[!, 1])
        l2::Vector{Int64} = sort(input[!, 2])
        counts::Accumulator{Int64, Int64} = counter(l2)

        part1::Int = [abs(c[1] - c[2]) for c in zip(l1, l2)] |> sum
        part2::Int = [counts[i] * i for i in l1] |> sum

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.loadcsv(YEAR, DAY, test, "   ")
    end

end