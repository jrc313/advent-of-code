module Aoc202408

    const YEAR::Int = 2024
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

    @inline function isinbounds(bounds::Tuple{Int, Int}, a::CartesianIndex)
        return 0 < a[1] <= bounds[1] && 0 < a[2] <= bounds[2]
    end

    function solve(test::Bool)

        grid = parseinput(test)
        bounds = size(grid)
        nodes = Dict{Char, Vector{CartesianIndex}}()
        for (pos, type) in pairs(IndexCartesian(), grid)
            type == '.' && continue
            node = get!(() -> Int[], nodes, type)
            push!(node, pos)
        end

        antinodes = Set{CartesianIndex}()
        manyantinodes = Set{CartesianIndex}()
        for positions in values(nodes)
            for (a, b) in Iterators.product(positions, positions)
                a == b && continue
                dist = a - b
                an1 = a + dist
                an2 = b - dist
                isinbounds(bounds, an1) && push!(antinodes, an1)
                isinbounds(bounds, an2) && push!(antinodes, an2)
                push!(manyantinodes, a)
                push!(manyantinodes, b)
                while isinbounds(bounds, an1)
                    push!(manyantinodes, an1)
                    an1 = an1 + dist
                end
                while isinbounds(bounds, an2)
                    push!(manyantinodes, an2)
                    an2 = an2 - dist
                end
            end
        end

        part1 = length(antinodes)
        part2 = length(manyantinodes)

        return (part1, part2)
    end

    function parseinput(test::Bool)
        return AocUtils.loadcharmatrix(YEAR, DAY, test)
    end

end