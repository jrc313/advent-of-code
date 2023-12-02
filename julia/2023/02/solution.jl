module Aoc202302

    const YEAR::Int = 2023
    const DAY::Int = 2

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

        (invalid, gamesmax, gamecount) = parseinput(test, Dict("red" => 12, "green" => 13, "blue" => 14))

        part1 = setdiff(1:gamecount, invalid) |> sum
        part2 = [reduce(*, values(cubemax)) for cubemax in gamesmax] |> sum

        return (part1, part2)
    end

    function parseinput(test::Bool, maxcounts::Dict{String, Int})
        invalid::Set{Int} = Set()
        games::Vector{String} = AocUtils.getinputlines(YEAR, DAY, test)
        gamesmax::Vector{Dict{String, Int}} = []
        for (gamenum, gamestr) in enumerate(games)
            cubemax::Dict{String, Int} = Dict("red" => 0, "green" => 0, "blue" => 0)
            start::Int = findfirst(':', gamestr) + 2
            for setstr in split(gamestr[start:end], "; ")
                for cubestr in split(setstr, ", ")
                    spacepos = findfirst(' ', cubestr)
                    num = parse(Int, cubestr[1:spacepos - 1])
                    colour = cubestr[spacepos + 1:end]
                    num > maxcounts[colour] && push!(invalid, gamenum)
                    cubemax[colour] = max(num, cubemax[colour])
                end
            end
            push!(gamesmax, cubemax)
        end

        return (invalid, gamesmax, length(games))
    end

end