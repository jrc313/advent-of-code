module Aoc202306

    const YEAR::Int = 2023
    const DAY::Int = 6

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
        times::Vector{Int}, dists::Vector{Int} = parseinput(test)

        ranges = [getwinrange(t, dists[i] + 1) for (i, t) in enumerate(times)]
        part1 = reduce(*, ranges[1:end-1])
        part2 = ranges[end]

        return (part1, part2)
    end

    function getwinrange(time, dist)
        droot = √(time^2 - (4 * dist))
        return Int(abs(ceil((time - droot) / 2) - floor((time + droot) / 2))) + 1
    end

    function parseinput(test::Bool)
        return [[[parse(Int, num) for num in eachsplit(line[12:end])]; [parse(Int, replace(line[12:end], r"\s+" => ""))]]
                    for line in eachline(AocUtils.getinputfilename(YEAR, DAY, test))]
    end

end