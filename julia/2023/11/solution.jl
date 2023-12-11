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

        universe, olduniverse = getuniverse(2, test ? 10 : 1000000, test)

        galaxycount = length(universe)
        universedist::Int = 0
        olduniversedist::Int = 0

        for i in 1:galaxycount-1
            for j in i+1:galaxycount
                universedist += manhattandist(universe[i], universe[j])
                olduniversedist += manhattandist(olduniverse[i], olduniverse[j])
            end
        end
        
        part1 = universedist
        part2 = olduniversedist

        return (part1, part2)
    end

    function getuniverse(expansionfactor::Int, oldexpansionfactor::Int, test::Bool)
        universe::Vector{Point} = []
        olduniverse::Vector{Point} = []
        
        expansion::Int = 0
        oldexpansion::Int = 0
        input = getinputlines(YEAR, DAY, test)
        occupiedcols::Vector{Int} = zeros(length(input[1]))

        for (rownum, line) in enumerate(input)
            posinline::Vector{Int} = findall('#', line)
            if isempty(posinline)
                expansion += expansionfactor - 1
                oldexpansion += oldexpansionfactor - 1
            else
                append!(universe, [Point(pos, rownum + expansion) for pos in posinline])
                append!(olduniverse, [Point(pos, rownum + oldexpansion) for pos in posinline])
                for col in posinline
                    occupiedcols[col] = 1
                end
            end
        end
        
        for col = reverse(filter(c -> occupiedcols[c] == 0, 1:length(occupiedcols)))
            for (i, galaxy) in enumerate(universe)
                if galaxy.x > col
                    universe[i] = Point(galaxy.x + expansionfactor - 1, galaxy.y)
                    olduniverse[i] = Point(olduniverse[i].x + oldexpansionfactor - 1, olduniverse[i].y)
                end
            end
        end

        return universe, olduniverse
    end

end