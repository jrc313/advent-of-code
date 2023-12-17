module Aoc202317

    const YEAR::Int = 2023
    const DAY::Int = 17

    export solve

    include("../../AocUtils.jl")
    using .AocUtils, DataStructures

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const BORDER::Int = 0
    const POINT_DIR_MAP::Dict{Point, Char} = Dict(POINT_DOWN => 'D', POINT_UP => 'U', POINT_LEFT => 'L', POINT_RIGHT => 'R')

    mutable struct PathItem
        pos::Point
        dir::Point
        energy::Int # Use this to record how long we've travelled in the same direction
    end

    Base.show(io::IO, p::PathItem) = print(io, "$(p.pos):$(p.energy) -> $(POINT_DIR_MAP[p.dir])")

    function itemhash(p::PathItem)
        return p.pos.x << 32 + p.pos.y << 6 + (p.dir.x + 1) << 4 + (p.dir.y + 1) << 2 + p.energy
    end

    function nextdirs(item::PathItem)
        reversedir::Point = item.dir * -1
        item.energy < 3 && return filter(c -> c != reversedir, POINT_NEIGHBOURS)
        return filter(c -> c != item.dir && c != reversedir, POINT_NEIGHBOURS)
    end

    function nextpathitems(item::PathItem)
        return [PathItem(item.pos + d, d, item.energy == 3 ? 0 : item.energy + 1) for d in nextdirs(item)]
    end

    function solve(test::Bool)
        grid::Matrix{Int} = parseinput(test)
        h, w = size(grid)

        start::Vector{PathItem} = [PathItem(Point(2, 2), POINT_RIGHT, 0)]
        dest::Point = Point(w - 1, h - 1)

        showvar(grid)

        part1 = dijkstra(grid, start, dest)
        part2 = 0

        return (part1, part2)
    end

    function dijkstra(grid::Matrix{Int}, start::Vector{PathItem}, dest::Point)
        seenstates::Set{Int} = Set()
        queue::PriorityQueue{PathItem, Int} = PriorityQueue()
        for item in start
            push!(seenstates, itemhash(item))
            enqueue!(queue, item => 0)
        end

        while length(queue) > 0
            item::PathItem, heat::Int = peek(queue)
            item.pos == dest && return heat
            dequeue!(queue)
            for nextitem in filter(nitem -> itemhash(nitem) ∉ seenstates && grid[nitem.pos.x, nitem.pos.y] != 0, nextpathitems(item))
                push!(seenstates, itemhash(item))
                enqueue!(queue, nextitem => heat + grid[nextitem.pos.x, nextitem.pos.y])
            end
        end

        return 0
    end

    function parseinput(test::Bool)
        m::Matrix{Int} = AocUtils.loadintmatrix(YEAR, DAY, test)
        h, w = size(m)
        m = vcat(zeros(1, w), m, zeros(1, w))
        m = hcat(zeros(h + 2, 1), m, zeros(h + 2, 1))
        return m
    end

end