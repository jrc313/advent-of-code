module Aoc202214

    const YEAR::Int = 2022
    const DAY::Int = 14

    const POUR_COL::Int = 500
    const AIR::Int = 0
    const WALL::Int = 1
    const SAND::Int = 2
    const SPRITES::Vector{Char} = ['.', '#', 'o']

    struct Cave
        pourcol::Int
        grid::Matrix{Int}
    end

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

        cave = parseinput(test)
        
        part1 = runsand(cave)

        p2visible = part1 + runsand(cave, false)
        p2rest = calcedges(cave)
        part2 = p2visible + p2rest

        #println(drawcave(cave))

        return (part1, part2)
    end

    function runsand(cave::Cave, emptycheck = true)
        startingpos = CartesianIndex(1, cave.pourcol)
        pos = startingpos
        sandcount = 0
        while true
            candidates = filter(c -> checkbounds(Bool, cave.grid, c),
                                    [pos + CartesianIndex(1, 0),
                                     pos + CartesianIndex(1, -1),
                                     pos + CartesianIndex(1, 1)])
            
            emptycheck && isempty(candidates) && return sandcount

            nextposind = findfirst(c -> cave.grid[c] == AIR, candidates)

            if isnothing(nextposind)
                cave.grid[pos] = SAND
                sandcount += 1
                cave.grid[startingpos] == SAND && return sandcount
                pos = startingpos
            else
                pos = candidates[nextposind]
            end
        end
    end

    function calcedges(cave::Cave)
        trinum = function(edge::Vector{Int})
            trinumber = length(edge) - findfirst(c -> c == SAND, edge)
            return trinumber * (trinumber + 1) ÷ 2
        end

        return trinum(cave.grid[:, 1]) + trinum(cave.grid[:, end])
    end

    function drawcave(cave::Cave)
        cavestr::String = lpad("v", cave.pourcol, " ")
        for i in 1:size(cave.grid, 1)
            cavestr *= "\n" * join([SPRITES[n+1] for n in cave.grid[i, :]])
        end
        return cavestr
    end

    function parseinput(test::Bool)
        filename = AocUtils.getinputfilename(YEAR, DAY, test)
        walls = Vector{CartesianIndex{2}}()
        for line in eachline(filename)
            pairs = [[pair for pair in split(coord, ",")] for coord in eachsplit(line, " -> ")]
            inds = [CartesianIndex(parse(Int, y), parse(Int, x)) for (x, y) in pairs]
            ends = [(inds[i], inds[i+1]) for i in 1:length(inds)-1]
            expanded = [wall for wall in Iterators.flatten([vec(a <= b ? [i for i in a:b] : [i for i in b:a]) for (a, b) in ends])]
            append!(walls, expanded)
        end

        mn = minimum(walls) + CartesianIndex(0, -1)
        mx = maximum(walls) + CartesianIndex(1, 1)
        bounds = mx - mn + CartesianIndex(mn[1] + 1, 1)
        delta = mn - CartesianIndex(mn[1] + 1, 1)

        pourcol = POUR_COL - mn[2] + 1

        cavegrid = zeros(Int, bounds[1], bounds[2])

        map(ind -> cavegrid[ind - delta] = WALL, walls)

        return Cave(pourcol, cavegrid)
    end

end