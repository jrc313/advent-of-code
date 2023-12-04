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

        part1 = [1 << (matchcount - 1) for matchcount in matches] |> sum
        part2 = sum(copies)

        return (part1, part2)
    end

    function parseinput(test::Bool)
        cards::Vector{Int} = []

        lines = AocUtils.getinputlines(YEAR, DAY, test)
        numstart, numcount = countnumoncard(lines[1])

        for line in lines
            nums = collect(eachsplit(line[numstart:end]))
            cardnums = nums[1:numcount]
            mynums = nums[numcount+2:end]
            matches::Int = reduce((tally, n) -> (n in mynums) ? tally + 1 : tally, cardnums, init = 0)
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