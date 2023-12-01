module Aoc202301

    const YEAR::Int = 2023
    const DAY::Int = 01

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

        input::Vector{String} = parseinput(test)

        part1 = [getcalibrationvalue(line) for line in input] |> sum
        part2 = [getcalibrationvaluewords(line) for line in input] |> sum

        return (part1, part2)
    end

    function wordstonums(line::String, rev::Bool = false)
        return rev ? replace(reverse(line), "evif" => "5", "enin" => "9", "thgie" => "8", "neves" => "7", "ruof" => "4", "eno" => "1", "eerht" => "3", "xis" => "6", "owt" => "2") :
            replace(line, "one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9")
    end

    function getcalibrationvalue(line::String)
        findex = findfirst(c -> isnum(c), line)
        lindex = findlast(c -> isnum(c), line)
        if isnothing(findex)
            return 0
        end
        return parse(Int, line[findex] * line[lindex])
    end

    function getcalibrationvaluewords(line::String)
        fline = wordstonums(line)
        lline = wordstonums(line, true)
        findex = findfirst(c -> isnum(c), fline)
        lindex = findfirst(c -> isnum(c), lline)
        if isnothing(findex)
            return 0
        end
        return parse(Int, fline[findex] * lline[lindex])
    end

    function isnum(c::Char)
        return Int(c) < 58 && Int(c) > 47
    end

    function parseinput(test::Bool)
        return AocUtils.getinputlines(YEAR, DAY, test)
    end

end