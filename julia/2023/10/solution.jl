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

    const ADJ_MAP::Vector{Vector{Point}} =
        [[POINT_UP, POINT_DOWN], [POINT_LEFT, POINT_RIGHT], [POINT_UP, POINT_RIGHT],
        [POINT_UP, POINT_LEFT], [POINT_DOWN, POINT_LEFT], [POINT_DOWN, POINT_RIGHT]]

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

    function shoelace(points::Vector{Point}, perimeter::Int)
        s1::Int = s2::Int = 0
        push!(points, points[1])
        for i in eachindex(points[1:end-1])
            s1 += points[i].x * points[i+1].y
            s2 += points[i+1].x * points[i].y
        end

        return (abs(s1 - s2) - perimeter) ÷ 2 + 1
    end

    function getpath(start::CartesianIndex, field::Matrix{Int})
        startpoint::Point = Point(start[1], start[2])
        corners::Vector{Point} = [startpoint]
        prev::Point = startpoint
        current::Point = startpoint + ADJ_MAP[field[start]][1]
        pathlength::Int = 1

        while current != startpoint
            currentval::Int = field[current.x, current.y]
            3 <= currentval <= 6 && push!(corners, current)
            next::Point = current + ADJ_MAP[currentval][1] == prev ? current + ADJ_MAP[currentval][2] : current + ADJ_MAP[currentval][1]
            pathlength += 1
            prev = current
            current = next
        end

        maxdist::Int = pathlength ÷ 2
        enclosedcount = shoelace(corners, pathlength)

        return (maxdist, enclosedcount)
    end

    function getstype(pos::CartesianIndex, field::Matrix{Int})
        pospoint::Point = Point(pos[1], pos[2])
        neighbours = getneighbours(pospoint, size(field))
        connections = filter(n -> field[n.x, n.y] != 0 && (ADJ_MAP[field[n.x, n.y]][1] + n == pospoint || ADJ_MAP[field[n.x, n.y]][2] + n == pospoint), neighbours)
        offsets = [connections[1] - pospoint, connections[2] - pospoint]
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