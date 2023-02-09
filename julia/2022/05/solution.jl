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

        stacks, moves = parseinput(test)

        part1 = runcrane(deepcopy(stacks), moves)
        part2 = runcrane(stacks, moves, false)

        return (part1, part2)
    end

    function runcrane(stacks::Vector{Vector{Char}}, moves::Vector{Tuple{Int, Int, Int}})
        runcrane(stacks, moves, true)
    end

    function runcrane(stacks::Vector{Vector{Char}}, moves::Vector{Tuple{Int, Int, Int}}, onePer::Bool)
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

    function parsestackstring(stackstring::AbstractString)
        lines = split(stackstring, "\n")

        stacks = [Vector{Char}(undef, 0) for _ in (1:(length(lines[1]) + 1) ÷ 4)]

        for line in lines[end - 1:-1:1]
            for (i, c) in enumerate(line[2:4:end])
                !isspace(c) && push!(stacks[i], only(c))
            end
        end

        return stacks
    end

    function parsemovestring(movestring::AbstractString)
        return map(c -> (parse.(Int, (c[2], c[4], c[6]))), [split(line) for line in eachsplit(movestring, "\n", keepempty = false)])
    end

    function parseinput(test::Bool)
        input = AocUtils.getinput(YEAR, DAY, test)
        stackstring::String, movestring::String = split(input, "\n\n");

        stacks = parsestackstring(stackstring)
        moves = parsemovestring(movestring)

        return stacks, moves
    end

end