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

        moves = parseinput(test)

        part1 = solvepart1(moves)
        part2 = solvepart2(moves)

        return (part1, part2)
    end

    function solvepart1(moves::Vector{Tuple{Int, Int}})
        map(move::Tuple{Int, Int} ->
            begin
                op, me = move
                op == me && return me + 3
                win_map[me] == op && return me + 6
                return me
            end, moves) |> sum
    end

    function solvepart2(moves::Vector{Tuple{Int, Int}})
        map(move::Tuple{Int, Int} ->
            begin
                op, res = move
                res == 1 && return win_map[op]
                res == 2 && return op + 3
                return lose_map[op] + 6
            end, moves) |> sum
    end

    function parseline(line::AbstractString)
        c::Vector{Char} = collect(line)
        return (Int(c[1]) - 64, Int(c[3]) - 87)
    end

    function parseinput(test::Bool)
        filename::String = AocUtils.getinputfilename(YEAR, DAY, test)

        open(filename) do file
            return [parseline(line) for line in eachline(file)]
        end
    end

end