module Aoc202324

    const YEAR::Int = 2023
    const DAY::Int = 24

    export solve

    include("../../AocUtils.jl")
    using .AocUtils, LinearAlgebra

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    struct Stone
        p::Point3d
        v::Point3d
        m::Float64 # Gradient: rise / run
        Stone(p::Point3d, v::Point3d) = new(p, v, v.y / v.x)
    end

    function solve(test::Bool)

        stones = parseinput(test)
        
        intersectcount = 0

        for (i, s1) in enumerate(stones[1:end-1])
            for s2 in stones[i+1:end]
                ix = intersect2d(s1, s2)
                isnothing(ix) && continue
                intersectcount += 1
                println("Intersect between $s1 and $s2 at $ix")
            end
        end

        part1 = intersectcount
        part2 = 0

        return (part1, part2)
    end

    function intersect2d(s1::Stone, s2::Stone)
        A::Matrix{Float64} = [1 -s1.m; 1 -s2.m]
        b::Vector{Float64} = [s1.p.y - (s1.m * s1.p.x), s2.p.y - (s2.m * s2.p.x)]

        det(A) == 0 && return nothing

        ix = A\b
        return Point{Float64}(ix[2], ix[1])
    end

    function intersect(s1::Stone, s2::Stone)
        A::Matrix{Int} = [s1.v.x -s2.v.x; s1.v.y -s2.v.y]
        b::Vector{Int} = [s2.p.x - s1.p.x, s2.p.y - s1.p.y]

        det(A) == 0 && return nothing

        x = A\b
        println(x)
        t = x[1]
        s = x[2]
        ft = (t, p, v) -> t * v + p
        s1x = (ft(t, s1.v.x, s1.p.x), ft(t, s1.v.y, s1.p.y), ft(t, s1.v.z, s1.p.z))
        s2x = (ft(s, s2.v.x, s2.p.x), ft(s, s2.v.y, s2.p.y), ft(s, s2.v.z, s2.p.z))
        println("ix: $s1x : $s2x")
        return (ft(t, s1.v.x, s1.p.x), ft(t, s1.v.y, s1.p.y), ft(t, s1.v.z, s1.p.z))
    end

    function parseinput(test::Bool)
        fn = p -> Stone(Point3d(parse(Int, p[1]), parse(Int, p[2]), parse(Int, p[3])), Point3d(parse(Int, p[4]), parse(Int, p[5]), parse(Int, p[6])))
        return [fn(split(line, [',', ' ', '@'], keepempty = false)) for line in AocUtils.eachinputlines(YEAR, DAY, test)]
    end

end