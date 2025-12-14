module Aoc202508

    const YEAR::Int = 2025
    const DAY::Int = 8

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    struct BoxPair
        a::Point3d
        b::Point3d
        dist::Real
    end
    
    Base.show(io::IO, p::BoxPair) = print(io, "a: $(p.a)\tb: $(p.b)\tdist: $(p.dist)")

    function solve(test::Bool)

        part1 = 0
        part2 = 0

        boxes::Vector{Point3d} = [parse(Point3d, line) for line in AocUtils.eachinputlines(YEAR, DAY, test)]
        boxdists::Vector{BoxPair} = []
        
        for (i, box1) in enumerate(boxes)
            for box2 in boxes[i+1:end]
                push!(boxdists, BoxPair(box1, box2, distance(box1, box2)))
            end
        end

        sort!(boxdists, by = a -> a.dist)

        circuits::Vector{Set{Point3d}} = []

        connected = Set()

        connections = 0
        pairnum = 1

        while length(connected) < length(boxes)
            pair = boxdists[pairnum]
            pairnum += 1
            connections += 1
            boxacircuit = 0
            boxbcircuit = 0
           
            for (i, circuit) in enumerate(circuits)
                boxacircuit == 0 && in(pair.a, circuit) && (boxacircuit = i)
                boxbcircuit == 0 && in(pair.b, circuit) && (boxbcircuit = i)
            end
            
            if boxacircuit == 0 && boxbcircuit == 0
                push!(circuits, Set([pair.a, pair.b]))
            elseif boxacircuit == 0
                push!(circuits[boxbcircuit], pair.a)
            elseif boxbcircuit == 0
                push!(circuits[boxacircuit], pair.b)
            elseif boxacircuit != boxbcircuit
                union!(circuits[boxacircuit], circuits[boxbcircuit])
                deleteat!(circuits, boxbcircuit)
            end
            
            union!(connected, [pair.a, pair.b])

            if connections == (test ? 10 : 1000)
                circuitlengths = length.(circuits)
                sort!(circuitlengths, rev = true)
                part1 = reduce(*, circuitlengths[1:3])
            end
            length(connected) == length(boxes) && (part2 = pair.a.x * pair.b.x)
        end

        connected = reduce((acc, circuit) -> union(acc, circuit), circuits, init = Set())
        

        return (part1, part2)
    end

end