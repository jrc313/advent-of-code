module Aoc202212

    const YEAR::Int = 2022
    const DAY::Int = 12

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

        start, target, terrain = parseinput(test)

        part1 = findpathlength(start, candidate -> candidate == target, (h, nexth) -> nexth <= h + 1, terrain)
        part2 = findpathlength(target, candidate -> terrain[candidate] == 1, (h, nexth) -> h <= nexth + 1, terrain)

        return (part1, part2)
    end

    function getneighbours(mat::Matrix{Int}, ind::CartesianIndex{2})
        return filter(c -> checkbounds(Bool, mat, c),
                        [ind - CartesianIndex(1, 0),
                         ind - CartesianIndex(0, 1),
                         ind + CartesianIndex(1, 0),
                         ind + CartesianIndex(0, 1)])
    end
    

    function findpathlength(start::CartesianIndex{2}, targetfn::Function, movefn::Function, terrain::Matrix{Int})
        visited = Set{CartesianIndex}()
        # Queue is tuple of path length and next step
        queue = Vector{Tuple{Int, CartesianIndex{2}}}()
        push!(queue, (0, start))

        while !isempty(queue)
            pathlength, nextstep = popfirst!(queue)

            # Test if this is the target and return the path length if it is
            targetfn(nextstep) && return pathlength

            height = terrain[nextstep]

            # Get the list of neighbours that pass the move function and haven't been visited yet
            for neighbour in filter(n -> movefn(height, terrain[n]) && n ∉ visited, getneighbours(terrain, nextstep))
                push!(visited, neighbour)
                push!(queue, (pathlength + 1, neighbour))
            end
        end

        return 0
    end

    function parseinput(test::Bool)
        start::CartesianIndex = CartesianIndex(0, 0)
        target::CartesianIndex = CartesianIndex(0, 0)
        charparsefn::Function = function(c::Char, ind::CartesianIndex)
            if c === 'S'
                start = ind
                return 1
            elseif c === 'E'
                target = ind
                return 26
            end
            
            return Int(c) - 96
        end
        terrain::Matrix{Int} = AocUtils.loadintmatrix(YEAR, DAY, test, charparsefn)
        
        return (start, target, terrain)
    end

end