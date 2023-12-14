module Aoc202313

    const YEAR::Int = 2023
    const DAY::Int = 13

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

        patterns = parseinput(test)

        println([isv ? l : l * 100 for (l, isv) in [findreflectionpoint(p) for p in patterns]])

        part1 = [isv ? l : l * 100 for (l, isv) in [findreflectionpoint(p) for p in patterns]] |> sum
        part2 = [isv ? l : l * 100 for (l, isv) in [findsmudgedreflectionpoint(p) for p in patterns]] |> sum

        return (part1, part2)
    end

    function getreflectioncandidates(pattern::Matrix{Bool})
        dim = size(pattern)
        vert::Vector{Int} = filter(i -> pattern[:, i] == pattern[:, i + 1], 1:dim[2]-1)
        horiz::Vector{Int} = filter(i -> pattern[i, :] == pattern[i + 1, :], 1:dim[1]-1)
        return (vert, horiz)
    end

    function countdiffs(a::Vector{Bool}, b::Vector{Bool})
        return count(i -> a[i] != b[i], eachindex(a))
    end

    function findsmudgedreflectionpoint(pattern::Matrix{Bool})
        dim = size(pattern)
        candidates = getreflectioncandidates(pattern)
        for candidate in candidates[1]
            println(candidate)
            for (i, j) in zip(candidate:-1:1, candidate+1:dim[2])
                if count(filter(count(pattern[:, i], pattern[:, j]) ==1, )
            end
            if count(filter(t -> countdiffs(pattern[:, t[1]], pattern[:, t[end]]) == 1, zip(candidate:-1:1, candidate+1:dim[2]))) == 1
                return (candidate, true)
            end
        end
    end

    function findreflectionpoint(pattern::Matrix{Bool})
        dim = size(pattern)
        candidates::Vector{Int} = filter(i -> pattern[:, i] == pattern[:, i + 1], 1:dim[2]-1)
        for candidate in candidates
            all(t -> pattern[:, t[1]] == pattern[:, t[end]], zip(candidate:-1:1, candidate+1:dim[2])) && (return (candidate, true))
        end
        candidates = filter(i -> pattern[i, :] == pattern[i + 1, :], 1:dim[1]-1)
        for candidate in candidates
            all(t -> pattern[t[1], :] == pattern[t[end], :], zip(candidate:-1:1, candidate+1:dim[1])) && (return (candidate, false))
        end

        return nothing
    end

    function buffertomatrix(buffer::Vector{String})::Matrix{Bool}
        return reduce(vcat, [permutedims([c == '#' for c in bline]) for bline in buffer])
    end

    function parseinput(test::Bool)
        buffer::Vector{String} = []
        patterns::Vector{Matrix{Bool}} = []
        for line in AocUtils.eachinputlines(YEAR, DAY, test)
            if isempty(line) && !isempty(buffer)
                push!(patterns, buffertomatrix(buffer))
                buffer = []
            else
                push!(buffer, line)
            end
        end

        !isempty(buffer) && push!(patterns, buffertomatrix(buffer))

        return patterns
    end

end