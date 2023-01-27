module Aoc202202

    const YEAR::Int = 2022
    const DAY::Int = 2

    export solve, test

    include("../../AocUtils.jl")
    import .AocUtils
    
    const win_map::Vector{Int} = [3, 1, 2]
    const lose_map::Vector{Int} = [2, 3, 1]


    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        moves = parseInput(test)

        part1 = solvePart1(moves)
        part2 = solvePart2(moves)

        return (part1, part2)
    end

    function solvePart1(moves::Vector{Tuple{Int, Int}})
        map(move::Tuple{Int, Int} ->
            begin
                op, me = move
                op == me && return me + 3
                win_map[me] == op && return me + 6
                return me
            end, moves) |> sum
    end

    function solvePart2(moves::Vector{Tuple{Int, Int}})
        map(move::Tuple{Int, Int} ->
            begin
                op, res = move
                res == 1 && return win_map[op]
                res == 2 && return op + 3
                return lose_map[op] + 6
            end, moves) |> sum
    end

    function parseLine(line::String)
        c::Vector{Char} = collect(line)
        return (Int(c[1]) - 64, Int(c[3]) - 87)
    end

    function parseInput(test::Bool)
        filename::String = AocUtils.getInputFilename(YEAR, DAY, test)

        open(filename) do file
            return [parseLine(line) for line in eachline(file)]
        end
    end

end