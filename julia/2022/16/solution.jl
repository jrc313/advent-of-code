module Aoc202216

    const YEAR::Int = 2022
    const DAY::Int = 16

    export solve

    include("../../AocUtils.jl")
    using .AocUtils, DataStructures

    mutable struct Node
        key::String
        val::Int
        edges::Dict{String, Int}
    end

    mutable struct Path
        score::Int
        dist::Int
        keys::Vector{String}
        dists::Vector{Int}
    end

    Base.:<(a::Path, b::Path) = (a.score < b.score)
    Base.:isless(a::Path, b::Path) = (a.score < b.score)

    Base.:push!(path::Path, key::String, val::Int, dist::Int, maxdist::Int) = begin
        path.dist += dist
        path.score += (maxdist - path.dist) * val
        push!(path.dists, path.dist)
        push!(path.keys, key)
    end

    Base.show(io::IO, n::Node) =
        print(io, "Node: $(n.key):$(n.val)\t$(length(n.edges)) edges:[" * join(["$key:$val" for (key, val) in n.edges], ", ") * "]")

    function dijkstra(graph::Dict{String, Node}, source::String, startdist::Int = 0)
        dists = Dict([key => key == source ? startdist : typemax(Int) for key in keys(graph)])
        queue = PriorityQueue(dists)

        while length(queue) > 0
            node = dequeue!(queue)
            nodedist = dists[node]
            for (neighbour, neighbourdist) in graph[node].edges
                knowndist = dists[neighbour]
                newdist = nodedist + neighbourdist
                if newdist < knowndist
                    dists[neighbour] = queue[neighbour] = newdist
                end
            end
        end

        delete!(dists, source)
        return dists
    end

    function fullyconnectandfilter!(graph::Dict{String, Node}, source::String = "AA")
        for nodekey in filter(key -> graph[key].val != 0 || key == source, keys(graph))
            newedges = dijkstra(graph, nodekey, 0)
            graph[nodekey].edges = newedges
        end
        zerokeys = filter(key -> graph[key].val == 0 && key != source, keys(graph))
        for key in zerokeys
            delete!(graph, key)
        end
        for key in keys(graph)
            graph[key].edges = filter(edge -> edge[1] ∉ zerokeys, graph[key].edges)
        end
    end

    function findallpaths(graph::Dict{String, Node}, start::String, maxdist::Int)
        paths = Vector{Path}()
        currentpath::Path = Path(0, 0, [start], [])
        maxscore = 0
        buildpaths(path::Path) = begin
            path.dist >= maxdist && return
            push!(paths, deepcopy(path))

            neighbours = graph[path.keys[end]].edges
            for key in filter(n -> n ∉ path.keys, keys(neighbours))
                neighbour::Node = graph[key]
                dist = neighbours[key] + 1
                newpath = deepcopy(path)
                push!(newpath, key, neighbour.val, dist, maxdist)
                newpath.score > maxscore && (maxscore = newpath.score)
                buildpaths(newpath)
            end
        end

        buildpaths(currentpath)
        sort!(paths, rev = true)
        return paths
    end

    function findbestdistinct(paths::Vector{Path})
        bestscore = 0

        for path in paths[1:end÷2]
            bestdistinctindex = findfirst(isdisjoint(path.keys, p.keys[2:end]) for p in paths)
            isnothing(bestdistinctindex) && continue
            bestdistinct = paths[bestdistinctindex]
            if bestscore < path.score + bestdistinct.score
                bestscore = path.score + bestdistinct.score
            end
        end

        return bestscore
    end

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        graph = parseinput(test)
        fullyconnectandfilter!(graph)

        part1 = findallpaths(graph, "AA", 30)[1].score
        part2 = findbestdistinct(findallpaths(graph, "AA", 26))

        return (part1, part2)
    end

    function parseinput(test::Bool)
        filename = AocUtils.getinputfilename(YEAR, DAY, test)
        nodes::Dict{String, Node} = Dict{String, Node}()
        for line in eachline(filename)
            matches = match(r"^Valve ([A-Z]+) has flow rate=([0-9]+); tunnels? leads? to valves? (.+)$", line)
            key = String(matches[1])
            rate = parse(Int, matches[2])
            neighbours = Dict([String(n) => 1 for n in split(matches[3], ", ")])
            if haskey(nodes, key)
                merge!(node[key].edges, neighbours)
            else
                push!(nodes, key => Node(key, rate, neighbours))
            end
        end

        return nodes
    end

end