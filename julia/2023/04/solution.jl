module Aoc202304

    const YEAR::Int = 2023
    const DAY::Int = 4

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

        matches = parseinput(test)

        copies = ones(Int, length(matches))
        for i in 1:(length(matches))
            if matches[i] > 0
                for j in i+1:i+matches[i]
                    copies[j] += copies[i]
                end
            end
        end

        part1 = [matchcount == 0 ? 0 : 2^(matchcount - 1) for matchcount in matches] |> sum
        part2 = sum(copies)

        return (part1, part2)
    end

    function parseinput(test::Bool)
        cards::Vector{Int} = []

        numstart = 0
        numcount = 0

        for (index, line) in enumerate(AocUtils.getinputlines(YEAR, DAY, test))
            if index == 1
                numstart, numcount = countnumoncard(line)
            end

            nums::Vector{Int} = [parse(Int, num) for num in eachsplit(line[numstart:end], [' ', '|'], keepempty = false)]
            matches::Int = length(intersect(nums[1:numcount], nums[numcount+1:end]))
            push!(cards, matches)
        end

        return cards
    end

    function countnumoncard(line)
        start = findfirst(':', line) + 2
        bar = findfirst('|', line)
        numcount = (bar - start) ÷ 3
        return (start, numcount)
    end

end