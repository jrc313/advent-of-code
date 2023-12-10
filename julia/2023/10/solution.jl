module Aoc202310

    const YEAR::Int = 2023
    const DAY::Int = 10

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    const SYMBOL_MAP::Dict{Char, Int} = Dict('|' => 1, '-' => 2, 'L' => 3, 'J' => 4,
                                             '7' => 5, 'F' => 6, '.' => 0, 'S' => -1)

    const PIPE_MAP::Vector{Char} = ['|', '-', '└', '┘', '┐', '┌']
    const TILE_OPEN::Int = 1
    const TILE_CLOSED::Int = 2
    const TILE_UP::Int = 3
    const TILE_DOWN::Int = 4
    const TILE_RIGHT::Int = 5
    const TILE_LEFT::Int = 6
    const TILE_DIR_MAP::Dict{CartesianIndex, Int} = Dict(GRID_UP => TILE_UP, GRID_DOWN => TILE_DOWN, GRID_LEFT => TILE_LEFT, GRID_RIGHT => TILE_RIGHT)
    const TILE_CHAR_MAP::Vector{Char} = [' ', 'X', 'U', 'D', 'R', 'L']

    const ADJ_MAP::Vector{Vector{CartesianIndex}} =
        [[GRID_UP, GRID_DOWN], [GRID_LEFT, GRID_RIGHT], [GRID_UP, GRID_RIGHT],
         [GRID_UP, GRID_LEFT], [GRID_DOWN, GRID_LEFT], [GRID_DOWN, GRID_RIGHT]]

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        start, field = parseinput(test)

        pathlength, enclosedcount = getpath(start, field)

        part1 = pathlength ÷ 2
        part2 = enclosedcount

        return (part1, part2)
    end

    function getpath(start::CartesianIndex, field::Matrix{Int})
        fieldsize = size(field)
        pathdirfield::Matrix{Int} = ones(Int, fieldsize)
        startdir = ADJ_MAP[field[start]][1]
        startdirisright = startdir == GRID_RIGHT
        prev::CartesianIndex = start
        prevdir::CartesianIndex = startdir
        current::CartesianIndex = start + startdir
        pathdirfield[start] = TILE_DIR_MAP[startdir]
        pathlength::Int = 1
        enclosedcount::Int = 0

        while current != start
            adjs::Vector{CartesianIndex} = ADJ_MAP[field[current]]
            dir::CartesianIndex = (current + adjs[1] == prev ? adjs[2] : adjs[1])
            next::CartesianIndex = current + dir
            # Fix the direction for angled pipes
            if field[current] > 2 && (dir == GRID_UP || dir == GRID_DOWN)
                dir = prevdir
            end
            pathdirfield[current] = TILE_DIR_MAP[dir]
            pathlength += 1
            prev = current
            prevdir = dir
            current = next
        end

        inside::Bool = false
        for (i, cell) in enumerate(pathdirfield)
            i % fieldsize[1] == 1 && (inside = false)
            if cell == TILE_RIGHT
                inside = startdirisright
            elseif cell == TILE_LEFT
                inside = !startdirisright
            end
            if cell == TILE_OPEN && inside
                enclosedcount += 1
            end
        end

        return (pathlength, enclosedcount)
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