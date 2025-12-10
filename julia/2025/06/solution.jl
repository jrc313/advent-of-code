module Aoc202506

    const YEAR::Int = 2025
    const DAY::Int = 6

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function matrix2nums(m::Matrix{Int}, byrow = true)::Vector{Int}
        iterfn = byrow ? eachrow : eachcol
        return [reduce((acc, i) -> i == -1 ? acc : acc * 10 + i, r, init = 0) for r in iterfn(m)]
    end

    function solve(test::Bool)::Tuple{Int, Int}

        part1::Int = 0
        part2::Int = 0

        numsmat::Matrix{Int}, ops::Vector{Tuple{Int, Function}} = parseinput(test)
        dims::Tuple{Int, Int} = size(numsmat)
        opcount::Int = length(ops)

        for (i::Int, (s::Int, op::Function)) in enumerate(ops)
            e::Int = i == opcount ? dims[2] : (ops[i + 1][1]) - 2
            slice::Matrix{Int} = numsmat[:, s:e]
            part1 += reduce(op, matrix2nums(slice, true))
            part2 += reduce(op, matrix2nums(slice, false))
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)::Tuple{Matrix{Int}, Vector{Tuple{Int, Function}}}
        input::Vector{SubString{String}} = split(AocUtils.getinput(YEAR, DAY, test), "\n", keepempty = false)
        numsmat::Matrix{Int} = reduce(vcat, [permutedims([s == ' ' ? -1 : Int(s) - 48 for s in line]) for line in input[1:end - 1]])
        ops::Vector{Tuple{Int, Function}} = [(i, c == '+' ? (+) : (*)) for (i, c) in enumerate(input[end]) if c != ' ']
        return numsmat, ops
    end

end