module Aoc202318

    const YEAR::Int = 2023
    const DAY::Int = 18

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const DIR_MAP::Dict{Char, Point} = Dict('U' => POINT_UP, 'D' => POINT_DOWN, 'L' => POINT_LEFT, 'R' => POINT_RIGHT,
                                            '0' => POINT_RIGHT, '1' => POINT_DOWN, '2' => POINT_LEFT, '3' => POINT_UP)

    struct Step
        dir1::Point
        len1::Int
        dir2::Point
        len2::Int
    end

    function linetostep(line::String)
        parts::Vector{String} = split(line, [' ', '(', '#', ')'], keepempty = false)
        return Step(DIR_MAP[parts[1][1]], parse(Int, parts[2]), DIR_MAP[parts[3][end]], parse(Int, "0x$(parts[3][1:end - 1])"))
    end

    function plantopoints(plan::Vector{Step})
        points1::Vector{Point} = [Point(1, 1)]
        len1::Int = 0
        points2::Vector{Point} = [Point(1, 1)]
        len2::Int = 0
        for step in plan[1:end]
            push!(points1, points1[end] + (step.dir1 * step.len1))
            len1 += step.len1
            push!(points2, points2[end] + (step.dir2 * step.len2))
            len2 += step.len2
        end

        return points1, len1, points2, len2
    end

    function bounds(points::Vector{Point})
        minh::Int = minw::Int = maxh::Int = maxw::Int = 1
        hoffset::Int = woffset::Int = 0
        for p in points
            minh = min(minh, p.x)
            minw = min(minw, p.y)
            maxh = max(maxh, p.x)
            maxw = max(maxw, p.y)
        end

        minh < 1 && (hoffset = 1 - minh)
        minw < 1 && (woffset = 1 - minw)
    end

    function shoelace(plan::Vector{Step})
        points1::Vector{Point}, perimeter1::Int, points2::Vector{Point}, perimeter2::Int = plantopoints(plan)
        s1::Int = s2::Int = s3::Int = s4::Int = 0
        push!(points1, points1[1])
        push!(points2, points2[1])
        for i in eachindex(points1[1:end-1])
            s1 += points1[i].x * points1[i+1].y
            s2 += points1[i+1].x * points1[i].y
            s3 += points2[i].x * points2[i+1].y
            s4 += points2[i+1].x * points2[i].y
        end

        return ((abs(s1 - s2) + perimeter1) ÷ 2) + 1, ((abs(s3 - s4) + perimeter2) ÷ 2) + 1
    end

    function solve(test::Bool)
        plan::Vector{Step} = parseinput(test)
        return shoelace(plan)
    end

    function parseinput(test::Bool)
        return [linetostep(line) for line in AocUtils.eachinputlines(YEAR, DAY, test)]
    end

end