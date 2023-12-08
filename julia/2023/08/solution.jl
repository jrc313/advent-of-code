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

        dirs, network = parseinput(test)
        ghoststarts = filter(n -> endswith(n, "A"), keys(network))

        part1 = getstepcount(dirs, network, "AAA", "ZZZ")
        part2 = [getstepcount(dirs, network, start, "Z", true) for start in ghoststarts] |> lcm

        return (part1, part2)
    end

    function getstepcount(dirs, network, start, dest, ghostwalk = false)
        node = start
        steps = 0
        dirindex = 1
        maxdirindex = length(dirs)
        destfn = ghostwalk ? n -> endswith(n, dest) : n -> n == dest
        while !destfn(node)
            node = network[node][dirs[dirindex]]
            steps += 1
            dirindex == maxdirindex ? dirindex = 1 : dirindex += 1
        end

        return steps
    end

    function parseinput(test::Bool)
        input = AocUtils.getinputlines(YEAR, DAY, test)

        dirs = [c == 'L' ? 1 : 2 for c in input[1]]
        network = Dict([line[1:3] => (line[8:10], line[13:15]) for line in input[3:end]])
        return dirs, network
    end

end