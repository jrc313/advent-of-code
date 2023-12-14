module Aoc202314

    const YEAR::Int = 2023
    const DAY::Int = 14

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    const PLATFORM_MAP::Dict{Char, Int} = Dict('.' => 0, '#' => 1, 'O' => 2)

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        platform = parseinput(test)
        
        megaload::Int = 0
        spinloads::Vector{Vector{Int}} = []
        found::Bool = false
        i::Int = 1
        while !found
            nextload::Vector{Int} = spincycle(platform)
            cycleindex::Union{Nothing, Int} = findfirst(l -> l == nextload, spinloads)
            if !isnothing(cycleindex)
                cyclelength = i - cycleindex
                megaload = (1000000000 - cycleindex) % cyclelength + cycleindex
                found = true
            end
            push!(spinloads, nextload)
            i += 1
        end

        part1 = spinloads[1][1]
        part2 = spinloads[megaload][2]

        return (part1, part2)
    end

    function spincycle(platform::Matrix{Int})
        h, w = size(platform)
        north::Int = tiltplatform(platform, CartesianIndex(1, 1):CartesianIndex(1, w), c -> CartesianIndex(1, c[2]):CartesianIndex(h, c[2]), GRID_UP)
        tiltplatform(platform, CartesianIndex(1, 1):CartesianIndex(h, 1), c -> CartesianIndex(c[1], 1):CartesianIndex(c[1], w), GRID_LEFT)
        south::Int = tiltplatform(platform, CartesianIndex(h, 1):CartesianIndex(h, w), c -> CartesianIndex(h, c[2]):CartesianIndex(-1, 1):CartesianIndex(1, c[2]), GRID_DOWN)
        tiltplatform(platform, CartesianIndex(1, w):CartesianIndex(h, w), c -> CartesianIndex(c[1], w):CartesianIndex(1, -1):CartesianIndex(c[1], 1), GRID_RIGHT)
        return [north, south]
    end

    function tiltplatform(platform::Matrix{Int}, outerrng::CartesianIndices, innerrngfn::Function, falldir::CartesianIndex)
        rowcount = size(platform)[1]
        loadsum::Int = 0
        comparefn::Function = <
        (falldir[1] < 0 || falldir[2] < 0) && (comparefn = >)
        for n in outerrng
            lastoccupied::CartesianIndex = n + falldir
            for m in innerrngfn(n)
                if platform[m] == 2 && comparefn(m, lastoccupied)
                    lastoccupied = lastoccupied - falldir
                    platform[m] = 0
                    platform[lastoccupied] = 2
                    loadsum += rowcount - lastoccupied[1] + 1
                else
                    platform[m] == 2 && (loadsum += rowcount - m[1] + 1)
                    platform[m] != 0 && (lastoccupied = m)
                end
            end
        end
        return loadsum
    end

    function parseinput(test::Bool)
        return AocUtils.loadintmatrix(YEAR, DAY, test, (c, p) -> PLATFORM_MAP[c])
    end

end