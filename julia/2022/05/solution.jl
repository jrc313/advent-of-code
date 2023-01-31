module Aoc202205

    const YEAR::Int = 2022
    const DAY::Int = 5

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        stacks, moves = parseInput(test)

        part1 = runCrane(deepcopy(stacks), moves)
        part2 = runCrane(stacks, moves, false)

        return (part1, part2)
    end

    function runCrane(stacks::Vector{Vector{Char}}, moves::Vector{Tuple{Int, Int, Int}})
        runCrane(stacks, moves, true)
    end

    function runCrane(stacks::Vector{Vector{Char}}, moves::Vector{Tuple{Int, Int, Int}}, onePer::Bool)
        for move in moves

            amt = move[1]
            from = stacks[move[2]]
            to = stacks[move[3]]
            moveStack = last(from, amt)
            append!(to, onePer ? reverse(moveStack) : moveStack)
            resize!(from, length(from) - amt)

        end

        return join([s[end] for s in stacks])
    end

    function parseStackString(stackString::String)
        lines = split(stackString, "\n")

        stacks = [Vector{Char}(undef, 0) for _ in (1:(length(lines[1]) + 1) ÷ 4)]

        for line in lines[end - 1:-1:1]
            for (i, c) in enumerate(line[2:4:end])
                !isspace(c) && push!(stacks[i], only(c))
            end
        end

        return stacks
    end

    function parseMoveString(moveString::String)
        return map(line -> begin
            c = split(line)
            (parse.(Int, (c[2], c[4], c[6])))
        end, eachsplit(moveString, "\n", keepempty = false))
    end

    function parseInput(test::Bool)
        input = AocUtils.getInput(YEAR, DAY, test)
        stackString::String, moveString::String = split(input, "\n\n");

        stacks = parseStackString(stackString)
        moves = parseMoveString(moveString)

        return stacks, moves
    end

end