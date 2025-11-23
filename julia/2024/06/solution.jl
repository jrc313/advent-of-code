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
    const DIRS = [GRID_UP, GRID_RIGHT, GRID_DOWN, GRID_LEFT]

    function rungrid(grid, pos, dir, visited, part)
        while checkbounds(Bool, grid, pos) #&& i < 100000
            i += 1
            nextpos = pos + DIRS[dir]
            if visited[nextpos] | dir > 0
                return 0
            end
            if checkbounds(Bool, grid, nextpos) && grid[nextpos] == BLOCK
                visited[pos] |= dir
                dir = mod1(dir + 1, 4)
            else
                visited[pos] |= dir
                pos = nextpos
            end
        end
        return part == 1 ? count(i -> i > 0, visited) : 0
    end

    function solve(test::Bool)

        

        grid = parseinput(test)
        visited = zeros(Int, size(grid))

        dir = 1
        pos = findfirst(c -> c == GUARD, grid)
        
        part1 = 0
        part2 = 0

        i = 1
        while checkbounds(Bool, grid, pos) #&& i < 100000
            i += 1
            nextpos = pos + DIRS[dir]
            if checkbounds(Bool, grid, nextpos) && grid[nextpos] == BLOCK
                visited[pos] |= dir
                dir = mod1(dir + 1, 4)
            else
                visited[pos] |= dir
                pos = nextpos
            end
        end

        #showvar(grid)
        #showvar(visited)

        return (count(i -> i > 0, visited), part2)
    end

    function parseinput(test::Bool)
        return AocUtils.loadcharmatrix(YEAR, DAY, test)
    end

end