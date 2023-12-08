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

    struct Hand
        rank::Int
        cardvals::Vector{Int}
        bid::Int
    end

    function Base.isless(a::Hand, b::Hand)
        a.rank == b.rank && isless(a.cardvals, b.cardvals) && return true
        isless(a.rank, b.rank) && return true
        return false
    end

    function solve(test::Bool)

        hands::Vector{Hand}, jhands::Vector{Hand} = parseinput(test)

        part1 = [rank * hand.bid for (rank, hand) in enumerate(sort(hands))] |> sum
        part2 = [rank * hand.bid for (rank, hand) in enumerate(sort(jhands))] |> sum

        return (part1, part2)
    end

    function parseinput(test::Bool)
        hands::Vector{Hand} = []
        jhands::Vector{Hand} = []
        for line in AocUtils.eachinputlines(YEAR, DAY, test)
            hand::String = line[1:5]
            bid::Int = parse(Int, line[7:end])
            cardvals::Vector{Int} = [CARD_VALS[c] for c in hand]
            jcardvals::Vector{Int} = [JCARD_VALS[c] for c in hand]
            cardcounts::Vector{Int} = sort(collect(values(counter(hand))), rev = true)
            jcount::Int = count('J', hand)
            jcardcounts::Vector{Int} = copy(cardcounts)
            if 5 > jcount > 0
                deleteat!(jcardcounts, findfirst(v -> v == jcount, jcardcounts))
                jcardcounts[1] += jcount
            end
            push!(hands, Hand(CARD_COUNT_RANKS[cardcounts], cardvals, bid))
            push!(jhands, Hand(CARD_COUNT_RANKS[jcardcounts], jcardvals, bid))
        end

        return (hands, jhands)
    end

end