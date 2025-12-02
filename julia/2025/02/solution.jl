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

    function isinvalid(idstr)
        len = length(idstr)
        !iseven(len) && return false
        halflen = len ÷ 2
        return idstr[1:halflen] == idstr[halflen+1:end]
    end

    function isinvalid2(idstr)
        idstr2 = idstr * idstr
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
                idstr = string(id)
                isinvalid(idstr) && (part1 += id)
                isinvalid2(idstr) && (part2 += id)
            end
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end