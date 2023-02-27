module Aoc202213

    const YEAR::Int = 2022
    const DAY::Int = 13

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

        packets = parseinput(test)

        part1 = packetsinrightorder(packets)
        part2 = sortpackets(packets)

        return (part1, part2)
    end

    function packetsinrightorder(packets)
        indexsum = 0
        for i in 1:2:length(packets)
            if comparepackets(packets[i], packets[i + 1]) == 1
                ind = (i + 1) ÷ 2
                indexsum += ind
            end
        end

        return indexsum
    end

    function sortpackets(packets)
        d1, d2 = [[2]], [[6]]

        push!(packets, d1)
        push!(packets, d2)
        sorted = sort(packets, lt = (a, b) -> comparepackets(a, b) == 1)

        return reduce(*, [p == d1 || p == d2 ? i : 1 for (i, p) in enumerate(sorted)])
    end

    function comparepackets(p1, p2)
        for (i, a) in enumerate(p1)
            !checkbounds(Bool, p2, i) && return -1
            b = p2[i]
            if isa(a, Array) || isa(b, Array)
                arraya = isa(a, Array) ? a : [a]
                arrayb = isa(b, Array) ? b : [b]
                result = comparepackets(arraya, arrayb)
                result != 0 && return result
            elseif a < b
                return 1
            elseif a > b
                return -1
            end
        end

        length(p1) == length(p2) && return 0
        return 1
    end

    function parseinput(test::Bool)
        filename = AocUtils.getinputfilename(YEAR, DAY, test)
        return [eval(Meta.parse(line)) for line in Iterators.filter(l -> !isempty(l), eachline(filename))]
    end

end