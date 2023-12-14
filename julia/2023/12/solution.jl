module Aoc202312

    const YEAR::Int = 2023
    const DAY::Int = 12

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const GOOD::Char = '.'
    const BAD::Char = '#'
    const UNKNOWN::Char = '?'

    function solve(test::Bool)

        records = parseinput(test)
        possible = [countpossible(r[1], r[end]) for r in records]
        println(possible)

        part1 = 0
        part2 = 0

        return (part1, part2)
    end

    function countpossible(springs::String, seqs::Vector{Int})
        springs = replace(strip(springs, GOOD), r"\.+" => ".")
        println("$springs : $seqs")
        sum(seqs) + length(seqs) - 1 == length(springs) && return 1

        for i in eachindex(seqs)
            chunkstart::Int = 1
            chunkend::Int = length(springs)
            i > 1 && (chunkstart = sum(seqs[1:i-1]) + length(1:i-1))
            i < chunkend && (chunkend = chunkend - (sum(seqs[i+1:end]) + length(seqs[i+1:end])))
            println("$(seqs[i]) ($chunkstart:$chunkend): $(springs[chunkstart:chunkend])")
        end

        groups = split(springs, GOOD, keepempty = false)
        length(groups[1]) < length(seqs[1]) && (groups = groups[2:end])
        length(groups[end]) < length(seqs[end]) && (groups = groups[1:end-1])

        #println("$(join(groups, ' ')) : $seqs")        


        return 0
    end

    function parseinput(test::Bool)
        records::Vector{Tuple{String, Vector{Int}}} = []
        for line in AocUtils.eachinputlines(YEAR, DAY, test)
            parts::Vector{String} = split(line, ' ')
            push!(records, (parts[1], [parse(Int, c) for c in split(parts[2], ',')]))
        end
        return records
    end

end