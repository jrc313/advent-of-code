module Aoc202407

    const YEAR::Int = 2024
    const DAY::Int = 7

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    @inline function numdigits(x::Int)::Int
        return Int(floor(log10(x))) + 1
    end

    function cancalibrate(i::Int, target::Int, equation::Vector{Int}, total::Int)
        total > target && (return false)
        i > length(equation) && (return total == target)
        return cancalibrate(i + 1, target, equation, total + equation[i]) ||
            cancalibrate(i + 1, target, equation, total * equation[i])
    end

    function cancalibrate2(i::Int, target::Int, equation::Vector{Int}, total::Int)
        total > target && (return false)
        i > length(equation) && (return total == target)
        return cancalibrate2(i + 1, target, equation, total + equation[i]) ||
            cancalibrate2(i + 1, target, equation, total * equation[i]) ||
            cancalibrate2(i + 1, target, equation, total * (10 ^ (numdigits(equation[i]))) + equation[i])
    end

    function solve(test::Bool)

        input = parseinput(test)
        part1 = 0
        part2 = 0
        for line in input
            if cancalibrate(1, line[1], line[3:end], line[2])
                part1 += line[1]
            else
                if cancalibrate2(1, line[1], line[3:end], line[2])
                    part2 += line[1]
                end
            end
        end

        return (part1, part1 + part2)
    end

    function parseinput(test::Bool)
        return [parse.(Int, split(line, [' ', ':'], keepempty = false)) for line in AocUtils.eachinputlines(YEAR, DAY, test)]
    end

end