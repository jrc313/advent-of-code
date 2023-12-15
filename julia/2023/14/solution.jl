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
            nextload::Vector{Int} = fastspincycle(platform)
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

    function fastspincycle(platform::Matrix)
        w = size(platform)[1]
        north::Int = tiltplatformfast(w, 1:w, 1:w, (a, b) -> platform[b, a], (a, b, v) -> platform[b, a] = v, <, +)
        tiltplatformfast(w, 1:w, 1:w, (a, b) -> platform[a, b], (a, b, v) -> platform[a, b] = v, <, +)
        south::Int = tiltplatformfast(w, 1:w, w:-1:1, (a, b) -> platform[b, a], (a, b, v) -> platform[b, a] = v, >, -)
        tiltplatformfast(w, 1:w, w:-1:1, (a, b) -> platform[a, b], (a, b, v) -> platform[a, b] = v, >, -)
        return [north, south]
    end

    function tiltplatformfast(h::Int,
                              outerrng::Union{UnitRange{Int}, StepRange{Int}}, innerrng::Union{UnitRange{Int}, StepRange{Int}},
                              getfn::Function, setfn::Function, comparefn::Function, incfn::Function)
        loadsum::Int = 0
        for m::Int in outerrng
            lastoccupied::Int = incfn(innerrng[1], -1)
            for n::Int in innerrng
                v::Int = getfn(m, n)
                if v == 2 && comparefn(lastoccupied, n)
                    lastoccupied = incfn(lastoccupied, 1)
                    loadsum += h - lastoccupied + 1
                    setfn(m, n, 0)
                    setfn(m, lastoccupied, 2)
                else
                    v == 2 && (loadsum += h - lastoccupied + 1)
                    v != 0 && (lastoccupied = n)
                end
            end
        end
        return loadsum
    end

    function parseinput(test::Bool)
        return AocUtils.loadintmatrix(YEAR, DAY, test, (c, p) -> PLATFORM_MAP[c])
    end

end