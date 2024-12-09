module Aoc202406

    const YEAR::Int = 2024
    const DAY::Int = 6

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const GUARD::Char = '^'
    const BLOCK::Char = '#'

    function solve(test::Bool)

        dirs = [GRID_UP, GRID_RIGHT, GRID_DOWN, GRID_LEFT]

        grid = parseinput(test)
        visited = zeros(Int, size(grid))

        dir = 1
        pos = findfirst(c -> c == GUARD, grid)
        
        part1 = 0
        part2 = 0

        i = 1
        while checkbounds(Bool, grid, pos) #&& i < 100000
            i += 1
            nextpos = pos + dirs[dir]
            if checkbounds(Bool, grid, nextpos) && grid[nextpos] == BLOCK
                dir = dir == length(dirs) ? 1 : dir + 1
            else
                visited[pos] = 1
                pos = nextpos
            end
        end

        return (sum(visited), part2)
    end

    function parseinput(test::Bool)
        return AocUtils.loadcharmatrix(YEAR, DAY, test)
    end

end