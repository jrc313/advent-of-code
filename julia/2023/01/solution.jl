module Aoc202301

    const YEAR::Int = 2023
    const DAY::Int = 1

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    const NUMMAP::Dict{String, Int} =
        Dict("owt" => 2, "4" => 4, "1" => 1, "eight" => 8, "2" => 2, "6" => 6,
             "one" => 1, "seven" => 7, "evif" => 5, "xis" => 6, "neves" => 7,
             "5" => 5, "six" => 6, "five" => 5, "enin" => 9, "thgie" => 8,
             "7" => 7, "eno" => 1, "three" => 3, "eerht" => 3, "8" => 8,
             "two" => 2, "four" => 4, "ruof" => 4, "nine" => 9, "9" => 9, "3" => 3)

    const NUMRX::Regex = r"(8|4|1|5|2|6|7|9|3)"
    const WORDRX::Regex = r"(two|four|six|eight|nine|one|three|five|seven|8|4|1|5|2|6|7|9|3)"
    const REVWORDRX::Regex = r"(evif|enin|thgie|neves|ruof|eno|eerht|xis|owt|8|4|1|5|2|6|7|9|3)"

    function solve(test::Bool)
        input::Vector{String} = parseinput(test)

        part1::Int = [getcalibrationvalue(line) for line in input] |> sum
        part2::Int = [getcalibrationvalue(line, true) for line in input] |> sum

        return (part1, part2)
    end

    function getcalibrationvalue(line::String, haswords::Bool = false)
        first::SubString{String} = match(haswords ? WORDRX : NUMRX, line).match
        last::SubString{String} = match(haswords ? REVWORDRX : NUMRX, reverse(line)).match

        return NUMMAP[first] * 10 + NUMMAP[last]
    end

    function parseinput(test::Bool)
        return AocUtils.getinputlines(YEAR, DAY, test)
    end

end