module Aoc202310

    const YEAR::Int = 2023
    const DAY::Int = 10

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    const SYMBOL_MAP::Dict{Char,Int} = Dict('|' => 1, '-' => 2, 'L' => 3, 'J' => 4,
                                            '7' => 5, 'F' => 6, '.' => 0, 'S' => -1)

    const PIPE_MAP::Vector{Char} = ['|', '-', '└', '┘', '┐', '┌']
    const TILE_OPEN::Int = 1
    const TILE_CLOSED::Int = -1
    const TILE_UP::Int = 3
    const TILE_DOWN::Int = 4
    const TILE_RIGHT::Int = 5
    const TILE_LEFT::Int = 6
    const TILE_DIR_MAP::Dict{CartesianIndex,Int} = Dict(GRID_UP => TILE_UP, GRID_DOWN => TILE_DOWN, GRID_LEFT => TILE_LEFT, GRID_RIGHT => TILE_RIGHT)
    const TILE_CHAR_MAP::Vector{Char} = [' ', 'X', '^', 'v', '>', '<']

    const ADJ_MAP::Vector{Vector{CartesianIndex}} =
        [[GRID_UP, GRID_DOWN], [GRID_LEFT, GRID_RIGHT], [GRID_UP, GRID_RIGHT],
        [GRID_UP, GRID_LEFT], [GRID_DOWN, GRID_LEFT], [GRID_DOWN, GRID_RIGHT]]

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        start, field = parseinput(test)

        maxdist, enclosedcount = getpath(start, field)

        part1 = maxdist
        part2 = enclosedcount

        return (part1, part2)
    end

    function getpath(start::CartesianIndex, field::Matrix{Int})
        fieldsize = size(field)
        pathfield::Matrix{Int} = zeros(Int, fieldsize)
        prev::CartesianIndex = start
        current::CartesianIndex = start + ADJ_MAP[field[start]][1]
        # Magic offset that fixes it for my input
        offset::Int = 5
        pathfield[start] = offset + 1
        pathlength::Int = 1
        enclosedcount::Int = 0

        while current != start
            next::CartesianIndex = current + ADJ_MAP[field[current]][1] == prev ? current + ADJ_MAP[field[current]][2] : current + ADJ_MAP[field[current]][1]
            pathlength += 1
            pathfield[current] = offset + pathlength
            prev = current
            current = next
        end

        maxdist::Int = pathlength ÷ 2

        inside::Bool = false
        fnfixlength = l::Int -> l > maxdist ? 2 * maxdist - l + 1 : l

        #AocUtils.showvar([c == 0 ? 0 : fnfixlength(c) for c in pathfield])
        
        
        for (i, cell) in enumerate(pathfield[fieldsize[1] + 1:end - 1])
            i % fieldsize[1] == 1 && (inside = false)
            if cell != 0 && pathfield[i] != 0
                if abs(fnfixlength(cell) - fnfixlength(pathfield[i])) == 1
                    inside = !inside
                end
            end

            if cell == 0 && inside
                enclosedcount += 1
                pathfield[i + fieldsize[1]] = TILE_CLOSED
            end
        end

        show([c == 0 ? '.' : c == -1 ? 'X' : field[i] == 0 ? ' ' : PIPE_MAP[field[i]] for (i, c) in enumerate(pathfield)])
        #println(maxdist)
        #AocUtils.showvar([c for c in pathfield])

        return (maxdist, enclosedcount)
    end

    function getstype(pos::CartesianIndex, field::Matrix{Int})
        neighbours = getneighbours(pos, size(field))
        connections = filter(n -> field[n] != 0 && (ADJ_MAP[field[n]][1] + n == pos || ADJ_MAP[field[n]][2] + n == pos), neighbours)
        offsets = [connections[1] - pos, connections[2] - pos]
        offsetsrev = reverse(offsets)
        return findfirst(d -> d == offsets || d == offsetsrev, ADJ_MAP)
    end

    function parseinput(test::Bool)
        start::CartesianIndex = CartesianIndex(1, 1)
        field::Matrix{Int} = AocUtils.loadmatrix(YEAR, DAY, test, (c, pos) -> SYMBOL_MAP[c])
        start = findfirst(n -> n == -1, field)
        field[start] = getstype(start, field)
        return start, field
    end

end