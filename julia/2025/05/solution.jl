module Aoc202505

    const YEAR::Int = 2025
    const DAY::Int = 5

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

        (rngs, ids) = parseinput(test)

        part1 = 0
        part2 = 0
        
        rngs = AocUtils.collapseranges(rngs)

        for id in ids
            for rng in rngs
                if rng[1] <= id <= rng[end]
                    part1 += 1
                    break
                end
            end
        end

        part2 = reduce((n, r) -> n += length(r), rngs, init = 0)

        return (part1, part2)
    end

    function parseinput(test::Bool)
        inputtext = AocUtils.getinput(YEAR, DAY, test)
        rngtext, idtext = split(inputtext, "\n\n", keepempty = false)

        rngs = map(r -> parse(Int, r[1]):parse(Int, r[2]), [[rngparts for rngparts in split(rng, "-")] for rng in split(rngtext, "\n", keepempty = false)])
        ids = [parse(Int, id) for id in split(idtext, "\n", keepempty = false)]
        return (rngs, ids)
    end

end