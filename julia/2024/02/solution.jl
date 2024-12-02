module Aoc202402

    const YEAR::Int = 2024
    const DAY::Int = 2

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()::Tuple{Int64, Int64}
        return solve(true)
    end

    function solve()::Tuple{Int64, Int64}
        return solve(false)
    end

    function getdists(row::Vector{Int})::Vector{Int}
        return [row[i] - row[i+1] for i in 1:length(row) - 1]
    end

    function issafe(dists::Vector{Int})::Bool
        return all(dists[1] > 0 ? (i -> 4 > i > 0) : (i -> -4 < i < 0), dists)
    end

    function solve(test::Bool)::Tuple{Int, Int}
        input::Vector{Vector{Int64}} = parseinput(test)

        part1::Int = 0
        part2::Int = 0

        for row in input
            dists::Vector{Int} = getdists(row)
            safe::Bool = issafe(dists)
            part1 += safe

            j::Int = 1
            rowlen::Int = length(row)
            while j <= rowlen && !safe
                newdists::Vector{Int} = deleteat!(copy(dists), min(j, rowlen - 1))
                if 1 < j < rowlen
                    newdists[j - 1] = row[j - 1] - row[j + 1]
                end
                safe = issafe(newdists)
                j += 1
            end
            part2 += safe
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)::Vector{Vector{Int64}}
        return [parse.(Int64, split(line)) for line in AocUtils.eachinputlines(YEAR, DAY, test)]
    end

end