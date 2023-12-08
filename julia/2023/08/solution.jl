module Aoc202308

    const YEAR::Int = 2023
    const DAY::Int = 8

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
        dirs, nodes, network = parseinput(test)

        ghoststarts::Vector{Int} = collect(values(filter(((k, v),) -> endswith(k, "A"), nodes)))
        ghostends::Vector{Int} = sort(collect(values(filter(((k, v),) -> endswith(k, "Z"), nodes))))

        part1 = getstepcount(dirs, network, nodes["AAA"], [nodes["ZZZ"]])
        part2 = [getstepcount(dirs, network, start, ghostends, true) for start in ghoststarts] |> lcm

        return (part1, part2)
    end

    function getstepcount(dirs::Vector{Int}, network::Vector{Tuple{Int, Int}}, start::Int, dests::Vector{Int}, ghostwalk::Bool = false)
        node = start
        steps = 0
        dircount = length(dirs)
        destfn = ghostwalk ? n -> n in dests : n -> n == dests[1]
        
        while !destfn(node)
            node = network[node][dirs[steps % dircount + 1]]
            steps += 1
        end

        return steps
    end

    function parseinput(test::Bool)
        input = AocUtils.getinputlines(YEAR, DAY, test)
        dirs = [c == 'L' ? 1 : 2 for c in input[1]]
        networkdata::Vector{Tuple{String, Int, String, String}} = [(line[1:3], i, line[8:10], line[13:15]) for (i, line) in enumerate(input[3:end])]
        nodes::Dict{String, Int} = Dict([node => index for (node, index, _, _) in networkdata])
        network::Vector{Tuple{Int, Int}} = [(nodes[l], nodes[r]) for (_, _, l, r) in networkdata]

        return dirs, nodes, network
    end

end