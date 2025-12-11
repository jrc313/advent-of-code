module Aoc202507

    const YEAR::Int = 2025
    const DAY::Int = 7

    export solve

    include("../../AocUtils.jl")
    using .AocUtils, Memoize

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        part1 = 0
        part2 = 0

        input::String = AocUtils.getinput(YEAR, DAY, test)
        startpos::Int = findfirst("S", input)[1]

        grid::Matrix{Bool} = reduce(vcat, [permutedims([s == '^' for s in line]) for line in split(input, keepempty = false)[2:end]])
        beams::Set{Int} = Set(startpos)
        beamgraph::Dict{CartesianIndex, Vector{CartesianIndex}} = Dict{CartesianIndex, Vector{CartesianIndex}}(CartesianIndex(1, startpos) => Vector{CartesianIndex}())
        
        for (i, row) in enumerate(eachrow(grid))
            nextbeams::Set{Int} = Set()
            for beam::Int in beams
                if row[beam]
                    part1 += 1
                    push!(nextbeams, beam - 1)
                    push!(nextbeams, beam + 1)
                    push!(beamgraph, CartesianIndex(i, beam) => [CartesianIndex(i + 1, beam - 1), CartesianIndex(i + 1, beam + 1)])
                else
                    push!(beamgraph, CartesianIndex(i, beam) => [CartesianIndex(i + 1, beam)])
                    push!(nextbeams, beam)
                end
            end
            beams = nextbeams
        end

        @memoize function countbeams(beamindex::CartesianIndex)
            # We have hit and end of the  beam
            !haskey(beamgraph, beamindex) && return 1
            return sum(countbeams(index) for index in beamgraph[beamindex])
        end

        part2 = countbeams(CartesianIndex(1, startpos))

        return (part1, part2)
    end

end