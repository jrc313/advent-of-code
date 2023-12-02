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
            gameparts = split(gamestr, [' ', ',', ';'])

            for i in 3:3:length(gameparts)
                num = parse(Int, gameparts[i])
                num > maxcounts[gameparts[i + 1]] && push!(invalid, gamenum)
                num > cubemax[gameparts[i + 1]] && (cubemax[gameparts[i + 1]] = num)
            end
            push!(gamesmax, cubemax)
        end

        return (invalid, gamesmax, length(games))
    end

end