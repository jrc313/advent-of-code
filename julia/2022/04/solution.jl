module Aoc202204

    const YEAR::Int = 2022
    const DAY::Int = 4

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

        pairs = parseinput(test)

        part1 = [⊆(p[1], p[2]) | ⊆(p[2], p[1]) for p in pairs] |> count
        part2 = [!isempty(∩(p[1], p[2])) for p in pairs] |> count

        return (part1, part2)
    end

    function parseline(line::AbstractString)
        nums = [parse(Int, c) for c in split(line, (',', '-'))]
        return ((nums[1] : nums[2]), (nums[3] : nums[4]))
    end

    function parseinput(test::Bool)
        filename::String = AocUtils.getinputfilename(YEAR, DAY, test)

        open(filename) do file
            return [parseline(line) for line in eachline(file)]
        end
    end

end