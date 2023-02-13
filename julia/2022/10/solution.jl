module Aoc202210

    const YEAR::Int = 2022
    const DAY::Int = 10

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

        cycles::Vector{Int} = parseinput(test)

        part1::Int = sum([cycles[n] * n for n in 20:40:220])
        crt::Vector{Char} = [n % 40 ∈ cycles[n]:cycles[n]+2 ? '#' : ' ' for n in 1:240]
        part2::String = join([join(crt[n:n+39]) for n in 1:40:240], "\n")

        return (part1, part2)
    end

    function parseinput(test::Bool)
        filename = AocUtils.getinputfilename(YEAR, DAY, test)
        x::Int = 1
        vals::Vector{Int} = [x]

        for line in eachline(filename)
            push!(vals, x)
            if line[1] != 'n'
                x += parse(Int, line[6:end])
                push!(vals, x)
            end
        end
        return vals
    end

end