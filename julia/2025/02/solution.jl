module Aoc202502

    const YEAR::Int = 2025
    const DAY::Int = 2

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function isinvalid(id)
        len = floor(log10(id)) + 1
        !iseven(len) && return false
        div = 10 ^ (len ÷ 2)
        return id ÷ div == id % div
    end

    function isinvalid2(id)
        idstr = string(id)
        idstr2 = idstr ^ 2
        return findfirst(idstr, idstr2[2:end])[1] != length(idstr)
    end

    function solve(test::Bool)

        input = parseinput(test)

        part1 = 0
        part2 = 0

        rngs = split(input, ',')

        for idrng in rngs
            rngstr = split(idrng, '-')
            rng = parse(Int, rngstr[1]):parse(Int, rngstr[2])
            for id in rng
                isinvalid(id) && (part1 += id)
                isinvalid2(id) && (part2 += id)
            end
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end