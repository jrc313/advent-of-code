module Aoc202305

    const YEAR::Int = 2023
    const DAY::Int = 5

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

        seeds, maps = parseinput(test)

        closest2 = typemax(Int64)
        for i in 1:2:length(seeds)
            rng = seeds[i]:seeds[i]+seeds[i+1]
            closest2 = min(closest2, closestseed(rng, maps))
        end

        part1 = closestseed(seeds, maps)
        part2 = closest2

        return (part1, part2)
    end

    function closestseed(seeds, seedmaps::Vector{Vector{Tuple{UnitRange{Int64}, Int64}}})

        #AocUtils.showvar(seeds)

        closest = typemax(Int64)
        for seed in seeds
            #print("$seed")
            for seedmap in seedmaps
                seed = mapvalue(seedmap, seed)
                #print(" -> $seed")
            end
            #println()
            closest = min(closest, seed)
        end

        #AocUtils.showvar(dests)
        return closest
    end

    function mapvalue(seedmaps::Vector{Tuple{UnitRange{Int64}, Int64}}, value::Int64)
        for seedmap in seedmaps
            if value in seedmap[1]
                return value + seedmap[2]
            end
        end

        return value
    end

    function combinemaps(m1::Vector{Tuple{UnitRange{Int64}, Int64}}, m2::Vector{Tuple{UnitRange{Int64}, Int64}})
        m2dict = Dict(m2 .=> ones(Int, length(m2)))
        for m1map in m1
            for m2map in keys(m2dict)
                if overlap(m1map, m2map)
                end
            end
        end
    end

    function overlap(r1::UnitRange{Int}, r2::UnitRange{Int})
        return r1.start <= r2.stop && r1.stop >= r2.start
    end

    function splitranges(r1::UnitRange{Int}, r2::UnitRange{Int})
        !overlap(r1, r2) && return [r1, r2]
        stops = sort(collect(Set([r1.start, r1.stop, r2.start, r2.stop])))
        return [(i > 1 ? stop + 1 : stop):stops[i + 1] for (i, stop) in enumerate(stops[1:end-1])]
    end

    function parseinput(test::Bool)

        input = AocUtils.getinputlines(YEAR, DAY, test)

        seeds::Vector{Int64} = [parse(Int, num) for num in eachsplit(input[1][8:end], ' ')]
        maps::Vector{Vector{Tuple{UnitRange{Int64}, Int64}}} = []
        mapnum::Int = 0
        for line in input[3:end]
            if endswith(line, ":")
                mapnum += 1
                push!(maps, [])
            elseif isempty(line)
                continue
            else
                ranges = [parse(Int, num) for num in split(line, ' ')]
                push!(maps[mapnum], (ranges[2]:ranges[2]+ranges[3], ranges[1] - ranges[2]))
            end

        end

        return (seeds, maps)

    end

end