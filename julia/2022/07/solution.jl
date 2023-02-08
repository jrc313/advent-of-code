module Aoc202207

    const YEAR::Int = 2022
    const DAY::Int = 7

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

        tree = parseInput(test)

        fssize = 70000000
        spacereq = 30000000
        deletesize = spacereq - (fssize - tree["/"])

        part1 = Iterators.filter(size -> size <= 100000, values(tree)) |> sum
        part2 = Iterators.filter(size -> size >= deletesize, values(tree)) |> minimum

        return (part1, part2)
    end

    function buildtree(input::AbstractString)
        cwd = Vector{AbstractString}()
        cwdString = ""
        tree = Dict{AbstractString, Int}()

        for line in Iterators.filter(s -> s[1:4] ∉ [raw"$ ls", "dir "], eachsplit(input, "\n", keepempty = false))
            if startswith(line, raw"$ cd ..")
                pop!(cwd)
                cwdString = join(cwd, "/")
            elseif startswith(line, raw"$ cd")
                push!(cwd, line[6:end])
                cwdString = join(cwd, "/")
                tree[cwdString] = 0
            else
                size = parse(Int, split(line)[1])
                for i in 1:length(cwd)
                    tree[join(cwd[1:i], "/")] += size
                end
            end
        end

        return tree
    end

    function parseInput(test::Bool)
        return buildtree(AocUtils.getInput(YEAR, DAY, test))
    end

end