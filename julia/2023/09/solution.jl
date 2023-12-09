module Aoc202309

    const YEAR::Int = 2023
    const DAY::Int = 9

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
        input::Vector{Vector{Int}} = parseinput(test)

        part1 = [nextinsequence(sequence) for sequence in input] |> sum
        part2 = [nextinsequence(reverse(sequence)) for sequence in input] |> sum

        return (part1, part2)
    end

    function nextinsequence(sequence::Vector{Int})
        length(unique(sequence)) == 1 && return sequence[1]
        diffsequence::Vector{Int} = [sequence[i] - sequence[i - 1] for i in 2:length(sequence)]
        sequenceend::Int = nextinsequence(diffsequence)
        return sequenceend + sequence[end]
    end

    function parseinput(test::Bool)
        [[parse(Int, c) for c in eachsplit(line, keepempty=false)] for line in AocUtils.eachinputlines(YEAR, DAY, test)]
    end

end