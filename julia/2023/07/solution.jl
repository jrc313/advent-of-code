module Aoc202307

    const YEAR::Int = 2023
    const DAY::Int = 7

    export solve

    include("../../AocUtils.jl")
    using .AocUtils
    using DataStructures

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const CARD_VALS::Dict{Char, Int} = Dict('2' => 1, '3' => 2, '4' => 3, '5' => 4, '6' => 5, '7' => 6, '8' => 7, '9' => 8, 'T' => 9, 'J' => 10, 'Q' => 11, 'K' => 12, 'A' => 13)
    const JCARD_VALS::Dict{Char, Int} = Dict('2' => 1, '3' => 2, '4' => 3, '5' => 4, '6' => 5, '7' => 6, '8' => 7, '9' => 8, 'T' => 9, 'J' => 0, 'Q' => 11, 'K' => 12, 'A' => 13)
    const CARD_COUNT_RANKS::Dict{Vector{Int}, Int} = Dict([5] => 7, [4, 1] => 6, [3, 2] => 5, [3, 1, 1] => 4, [2, 2, 1] => 3, [2, 1, 1, 1] => 2, [1, 1, 1, 1, 1] => 1)

    function solve(test::Bool)

        hands = parseinput(test)

        part1 = reduce(+, [rank * hand[5] for (rank, hand) in enumerate(sort(hands, lt = (a, b) -> handisless((a[1], a[2]), (b[1], b[2]))))])
        part2 = reduce(+, [rank * hand[5] for (rank, hand) in enumerate(sort(hands, lt = (a, b) -> handisless((a[3], a[4]), (b[3], b[4]))))])

        return (part1, part2)
    end

    function handisless(a::Tuple{Int, Vector{Int}}, b::Tuple{Int, Vector{Int}})
        isless(a[1], b[1]) && return true
        isless(b[1], a[1]) && return false
        isless(a[2], b[2]) && return true
        return false
    end

    function parseinput(test::Bool)
        hands = []
        for line in AocUtils.eachinputlines(YEAR, DAY, test)
            hand = line[1:5]
            bid = parse(Int, line[7:end])
            cardvals = [CARD_VALS[c] for c in hand]
            jcardvals = [JCARD_VALS[c] for c in hand]
            cardcounts = sort(collect(values(counter(hand))), rev = true)
            jcount = count('J', hand)
            jcardcounts = copy(cardcounts)
            if 5 > jcount > 0
                deleteat!(jcardcounts, findfirst(v -> v == jcount, jcardcounts))
                jcardcounts[1] += jcount
            end
            push!(hands, (CARD_COUNT_RANKS[cardcounts], cardvals, CARD_COUNT_RANKS[jcardcounts], jcardvals, bid))
        end

        return hands
    end

end