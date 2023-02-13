module Aoc202209

    const YEAR::Int = 2022
    const DAY::Int = 9

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

        steps = parseinput(test)
        return runsteps(steps, 9)
    end

    function movehead(step::Char, head::Tuple{Int, Int})
        step == 'R' && return (head[1] + 1, head[2])
        step == 'L' && return (head[1] - 1, head[2])
        step == 'U' && return (head[1], head[2] + 1)
        step == 'D' && return (head[1], head[2] - 1)
    end
    
    function movetail(rope::AbstractArray{Tuple{Int, Int}})
        for i in 2:lastindex(rope)
            x::Int, y::Int = rope[i]
            px::Int, py::Int = rope[i - 1]

            dx::Int = px - x
            dy::Int = py - y
            absdx = abs(dx)
            absdy = abs(dy)

            newx = x + (absdx > 1 || (absdx == 1 && absdy > 1) ? sign(dx) : 0)
            newy = y + (absdy > 1 || (absdy == 1 && absdx > 1) ? sign(dy) : 0)

            x == newx && y == newy && return

            rope[i] = (newx, newy)
        end
    end

    function runsteps(steps::Vector{Char}, taillength::Int)
        start::Tuple{Int, Int} = (0, 0)
        visitedfront::Set{Tuple{Int, Int}} = Set{Tuple{Int, Int}}()
        visitedend::Set{Tuple{Int, Int}} = Set{Tuple{Int, Int}}()
        push!(visitedfront, start)
        push!(visitedend, start)
        rope::Vector{Tuple{Int, Int}} = fill(start, taillength + 1)

        for step in steps
            rope[1] = movehead(step, rope[1])
            movetail(rope)
            push!(visitedfront, rope[2])
            push!(visitedend, rope[end])
        end

        return (length(visitedfront), length(visitedend)) 
    end

    function parseinput(test::Bool)
        filename = AocUtils.getinputfilename(YEAR, DAY, test)

        steps = Vector{Char}()
        for line in readlines(filename)
            instruction = split(line, " ")
            append!(steps, fill(only(instruction[1]), parse(Int, instruction[2])))
        end
        
        return steps
    end

end