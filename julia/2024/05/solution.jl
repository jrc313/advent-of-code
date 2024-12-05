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

        input = parseinput(test)
        rules = Set(r for r in input[1])
        ruleslt = (a, b) -> in("$(a)|$(b)", rules)
        updates = split.(input[2], ",")

        part1 = 0
        part2 = 0
        for update in updates
            if issorted(update, lt = ruleslt)
                part1 += parse(Int, middle(update))
            else
                part2 += parse(Int, middle(sort(update, lt = ruleslt)))
            end
        end
        
        return (part1, part2)
    end

    function parseinput(test::Bool)
        return split.(split(AocUtils.getinput(YEAR, DAY, test), "\n\n"), "\n")
    end

end