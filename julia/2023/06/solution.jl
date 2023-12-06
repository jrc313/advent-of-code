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
        times, dists = parseinput(test)
        #return (0, 0)
        p1ranges = [getwinrange(t, d + 1) for (t, d) in zip(times[1], dists[1])]
        p2range = getwinrange(times[2], dists[2] + 1)

        part1 = reduce(*, p1ranges)
        part2 = p2range

        return (part1, part2)
    end

    function getwinrange(time, dist)
        droot = √(time^2 - (4 * dist))
        return Int(abs(ceil((time - droot) / 2) - floor((time + droot) / 2))) + 1
    end

    function parseinput(test::Bool)
        lines = eachline(AocUtils.getinputfilename(YEAR, DAY, test))
        return [([parse(Int, num) for num in eachsplit(line[12:end])], parse(Int, replace(line[12:end], r"\s+" => ""))) for line in lines]
    end

end