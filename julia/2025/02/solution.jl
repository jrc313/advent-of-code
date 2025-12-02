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
        idstr = string(id)
        len = length(idstr)
        !iseven(len) && return false
        halflen = len ÷ 2
        idstr[1:halflen] == idstr[halflen+1:end] && return true
        return false
    end

    function isinvalid2(id)
        idstr = string(id)
        len = length(idstr)
        halflen = len ÷ 2
        for i in 1:halflen
            len % i != 0 && continue
            parts = Set()
            for l in 1:i:len
                push!(parts, idstr[l:l+(i-1)])
            end
            length(parts) == 1 && return true
        end
        return false
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