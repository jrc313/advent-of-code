module Aoc202508

    const YEAR::Int = 2025
    const DAY::Int = 8

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

    struct BoxPair
        a::Point3d
        b::Point3d
        dist::Real
    end
    
    Base.show(io::IO, p::BoxPair) = print(io, "a: $(p.a)\tb: $(p.b)\tdist: $(p.dist)")

    function Base.isless(a::BoxPair, b::BoxPair)
        return a.dist < b.dist
    end

    function getdists(boxes::Vector{Point3d})::BinaryMinHeap{BoxPair}
        boxdists::BinaryMinHeap{BoxPair} = BinaryMinHeap{BoxPair}()
        sizehint!(boxdists, binomial(length(boxes), 2))

        for (i::Int, box1::Point3d) in enumerate(boxes)
            for box2::Point3d in boxes[i+1:end]
                push!(boxdists, BoxPair(box1, box2, distancesquared(box1, box2)))
            end
        end

        return boxdists
    end

    function findpairincircuits(pair::BoxPair, circuits::Vector{Set{Point3d}})::Tuple{Int, Int}
        boxacircuit::Int = 0
        boxbcircuit::Int = 0
        
        for (i::Int, circuit::Set{Point3d}) in enumerate(circuits)
            boxacircuit == 0 && in(pair.a, circuit) && (boxacircuit = i)
            boxbcircuit == 0 && in(pair.b, circuit) && (boxbcircuit = i)
            boxacircuit != 0 && boxbcircuit != 0 && (break)
        end

        return (boxacircuit, boxbcircuit)
    end

    function addpairtocircuits(pair::BoxPair, circuits::Vector{Set{Point3d}})
        (boxacircuit::Int, boxbcircuit::Int) = findpairincircuits(pair, circuits)
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
    end

    function solve(test::Bool)

        part1 = 0
        part2 = 0

        boxes::Vector{Point3d} = parseinput(test)
        boxdists::BinaryMinHeap{BoxPair} = getdists(boxes)
        boxcount::Int = length(boxes)

        circuits::Vector{Set{Point3d}} = []

        connected::Set{Point3d} = Set()

        connections::Int = 0
        connectedcount::Int = 0

        while connectedcount < boxcount
            pair::BoxPair = pop!(boxdists)
            connections += 1
            addpairtocircuits(pair, circuits)
            
            union!(connected, [pair.a, pair.b])

            if connections == (test ? 10 : 1000)
                circuitlengths::Vector{Int} = length.(circuits)
                partialsort!(circuitlengths, 3, rev = true)
                part1 = reduce(*, circuitlengths[1:3])
            end
            connectedcount = length(connected)
            connectedcount == boxcount && (part2 = pair.a.x * pair.b.x)
        end

        return (part1, part2)
    end

    function parseinput(test::Bool)
        boxes::Vector{Point3d} = [parse(Point3d, line) for line in AocUtils.eachinputlines(YEAR, DAY, test)]
    end

end