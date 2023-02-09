module Aoc%Y%D0

    const YEAR::Int = %Y
    const DAY::Int = %D

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        input = parseinput(test)

        part1 = 0
        part2 = 0

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end