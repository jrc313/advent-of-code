module Aoc202405

    const YEAR::Int = 2024
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

    function middle(v)
        return v[length(v) >> 1 + length(v) % 2]
    end

    function solve(test::Bool)

        input::Tuple{Vector{String}, Vector{String}} = parseinput(test)
        rules::Set{String} = Set(r for r in input[1])

        ruleslt = (a::String, b::String) -> (a * "|" * b) ∈ rules

        part1::Int = 0
        part2::Int = 0
        for str::String in input[2]
            update::Vector{String} = [str[i:i+1] for i in 1:3:length(str)-1]
            middle::Int = length(update) >> 1 + 1
            if issorted(update, lt = ruleslt)
                part1 += parse(Int, update[middle])
            else
                partialsort!(update, middle, lt = ruleslt)
                part2 += parse(Int, update[middle])
            end
        end
        
        return (part1, part2)
    end

    function parseinput(test::Bool)
        rules = Vector{String}()
        updates = Vector{String}()
        vec = rules
        for line in AocUtils.eachinputlines(YEAR, DAY, test)
            if isempty(line)
                vec = updates
            else
                push!(vec, line)
            end
        end
        return (rules, updates)
    end

end