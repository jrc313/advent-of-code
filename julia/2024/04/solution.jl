module Aoc202404

    const YEAR::Int = 2024
    const DAY::Int = 4

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const X::Int = 1
    const M::Int = 100
    const A::Int = 10
    const S::Int = 1000
    const CHAR_MAP::Dict{Char, Int} = Dict('X' => X, 'M' => M, 'A' => A, 'S' => S)
    const XMAS::Vector{Int} = [X, M, A, S]

    function isxmas(puzzle::Matrix{Int}, row::Int, col::Int, rowfn, colfn)
        @inbounds for i::Int in 0:3
            puzzle[rowfn(row, i), colfn(col, i)] != XMAS[i + 1] && return false
        end
        return true
    end

    function solve(test::Bool)

        puzzle::Matrix{Int} = parseinput(test)
        
        part1::Int = 0
        part2::Int = 0

        rows::Int, cols::Int = size(puzzle)
        for row::Int in 4:rows - 3
            for col::Int in 4:cols - 3
                if puzzle[row, col] == X
                    isxmas(puzzle, row, col, (a, b) -> a, +) && (part1 += 1)
                    isxmas(puzzle, row, col, (a, b) -> a, -) && (part1 += 1)
                    isxmas(puzzle, row, col, +, (a, b) -> a) && (part1 += 1)
                    isxmas(puzzle, row, col, -, (a, b) -> a) && (part1 += 1)
                    isxmas(puzzle, row, col, -, +) && (part1 += 1)
                    isxmas(puzzle, row, col, -, -) && (part1 += 1)
                    isxmas(puzzle, row, col, +, +) && (part1 += 1)
                    isxmas(puzzle, row, col, +, -) && (part1 += 1)
                end

                if puzzle[row, col] == A
                    v::Vector{Int} = [puzzle[row - 1, col - 1], puzzle[row - 1, col + 1], puzzle[row + 1, col - 1], puzzle[row + 1, col + 1]]
                    sum(v) == 2200 && v[2] != v[3] && (part2 += 1)
                end
            end
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)
        puzzle::Matrix{Int} = AocUtils.loadintmatrix(YEAR, DAY, test, (c, pos) -> CHAR_MAP[c])
        h::Int, w::Int = size(puzzle)
        puzzle = vcat(zeros(Int, (3, w)), puzzle, zeros(Int, (3, w)))
        puzzle = hcat(zeros(Int, (h + 6, 3)), puzzle, zeros(Int, (h + 6, 3)))
        return puzzle
    end

end