module Aoc202303

    const YEAR::Int = 2023
    const DAY::Int = 3

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const SYMBOLS::Vector{Char} = ['=', '-', '*', '/', '+', '$', '&', '%', '#', '@']
    const GEAR::Char = '*'

    function solve(test::Bool)

        (partsum, gearratiosum) = parseinput(test)

        part1 = partsum
        part2 = gearratiosum

        return (part1, part2)
    end

    function parseinput(test::Bool)
        partsum = 0
        gears = Dict()

        inputmat = AocUtils.loadcharmatrix(YEAR, DAY, test)
        (nrows, ncols) = size(inputmat)
        
        clampr = n::Int -> clamp(n, 1, nrows)
        clampc = n::Int -> clamp(n, 1, ncols)
        featherbounds = (index, rng) -> CartesianIndex(clampr(index - 1), clampc(rng[1] - 1)):CartesianIndex(clampr(index + 1), clampc(rng[end] + 1))

        for (rownum, line) in enumerate(AocUtils.getinputlines(YEAR, DAY, test))
            for numrng in findall(r"[0-9]+", line)
                bounds = featherbounds(rownum, numrng)
                num = parse(Int, line[numrng])
                any(c -> c in SYMBOLS, inputmat[bounds]) && (partsum += num)
                
                for relativegearpos in findall(c -> c == GEAR, inputmat[bounds])
                    gearpos = bounds[1] + relativegearpos - CartesianIndex(1, 1)
                    !haskey(gears, gearpos) && (gears[gearpos] = [])
                    push!(gears[gearpos], num)
                end
            end
        end

        gearratiosum = [reduce(*, v) for (k, v) in filter(p -> length(p[2]) == 2, gears)] |> sum

        return (partsum, gearratiosum)
    end

end