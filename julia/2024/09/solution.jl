module Aoc202409

    const YEAR::Int = 2024
    const DAY::Int = 9

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

        input = (-).(collect(Int, parseinput(test)), 48)
        
        files = input[1:2:end]
        space = input[2:2:end]
        
        showvar(files)
        showvar(space)

        filenum = 1
        spacenum = 1
        rfilenum = length(files)
        blocknum = 0

        while filenum != rfilenum
            

        end

        part1 = 0
        part2 = 0

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.getinput(YEAR, DAY, test)
    end

end