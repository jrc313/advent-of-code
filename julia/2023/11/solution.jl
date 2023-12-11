module Aoc202311

    const YEAR::Int = 2023
    const DAY::Int = 11

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

        universe::Vector{Point}, olduniverse::Vector{Point} = getuniverse(1, test ? 9 : 999999, test)

        galaxycount::Int = length(universe)
        universedist::Int = 0
        olduniversedist::Int = 0

        for i in 1:galaxycount-1
            g1::Point = universe[i]
            og1::Point = olduniverse[i]
            for j in i+1:galaxycount
                universedist += manhattandist(g1, universe[j])
                olduniversedist += manhattandist(og1, olduniverse[j])
            end
        end

        return (universedist, olduniversedist)
    end

    function getuniverse(expansionfactor::Int, oldexpansionfactor::Int, test::Bool)
        universe::Vector{Point} = []
        olduniverse::Vector{Point} = []
        emptyrows::Int = 0
        input::Vector{String} = getinputlines(YEAR, DAY, test)
        colstatus::Vector{Int} = ones(length(input[1]))

        for (rownum::Int, line::String) in enumerate(input)
            posinline::Vector{Int} = findall('#', line)
            isempty(posinline) && (emptyrows += 1)
            for pos in posinline
                push!(universe, Point(pos, rownum + (expansionfactor * emptyrows)))
                push!(olduniverse, Point(pos, rownum + (oldexpansionfactor * emptyrows)))
                colstatus[pos] = 0
            end
        end

        emptycounts::Vector{Int} = cumsum(colstatus)
        for i::Int in eachindex(universe)
            g1::Point = universe[i]
            g2::Point = olduniverse[i]
            emptycolcount = emptycounts[g1.x]
            universe[i] = Point(g1.x + (expansionfactor * emptycolcount), g1.y)
            olduniverse[i] = Point(g2.x + (oldexpansionfactor * emptycolcount), g2.y)
        end

        return universe, olduniverse
    end

end