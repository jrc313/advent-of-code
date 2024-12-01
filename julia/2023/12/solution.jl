module Aoc202312

    const YEAR::Int = 2023
    const DAY::Int = 12

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    mutable struct Nonogram
        line::String
        runs::Vector{Int}
    end

    function Nonogram(s::String)
        parts = split(s, [' ', ','], keepempty = false)
        return Nonogram(parts[1], map(c -> parse(Int, c), parts[2:end]))
    end

    Base.show(io::IO, n::Nonogram) = print(io, "$(n.line) $(n.runs)")

    const GOOD::Char = '.'
    const BAD::Char = '#'
    const UNKNOWN::Char = '?'

    function solve(test::Bool)

        grams::Vector{Nonogram} = parseinput(test)
        lines = [(g, reduceline(g.line, g.runs)) for g in grams]
        showvar(lines)

        part1 = 0
        part2 = 0

        return (part1, part2)
    end

    function reduceline(line::String, runs::Vector{Int})
        line = replace(strip(line, GOOD), r"\.+" => ".")
        numruns = length(runs)
        sum(runs) + numruns - 1 == length(line) && return join(map(r -> repeat(BAD, r), runs), GOOD)

        for (i, runlength) in enumerate(runs)
            chunkstart::Int = 1
            chunkend::Int = length(line)
            i > 1 && (chunkstart = sum(runs[1:i-1]) + i)
            i < numruns && (chunkend = chunkend - (sum(runs[i+1:end]) + numruns - i))
            runstart::Int = chunkstart
            runend::Int = chunkstart + runlength - 1
            
            chunk = line[chunkstart:chunkend]
            chunklength = chunkend - chunkstart + 1
            # If the run is matched exactly in the chunk, make sure all GOOD chars are set
            runmatch::Union{Nothing, UnitRange{Int}} = findfirst(repeat(BAD, runlength), chunk)
            if !isnothing(runmatch)
                pos = runmatch[1] + chunkstart - 1
                line = markrunends(pos, pos + runlength - 1, line)
            elseif runlength > chunklength ÷ 2
                # If the run is matched partially in the chunk, make sure all GOOD and BAD chars are set
                runmatch = nothing #findfirst(Regex("(?<![#?])[#?]{$runlength}(?![#?])"), chunk)
                if !isnothing(runmatch)
                    runstart = chunkstart + runmatch[1] - 1
                    runend = chunkstart + runmatch[end] - 1
                    line = replacecharat(runstart:runend, BAD, line)
                    line = markrunends(runstart, runend, line)
                end
            end
            
            line = replace(strip(line, GOOD), r"\.+" => ".")

        end

        groups = split(line, GOOD, keepempty = false)
        length(groups[1]) < length(runs[1]) && (groups = groups[2:end])
        length(groups[end]) < length(runs[end]) && (groups = groups[1:end-1])

        return line
    end

    function markrunends(runstart::Int, runend::Int, line::String)
        ends::Vector{Int} = []
        runstart - 1 >= 1 && (push!(ends, runstart - 1))
        runend + 1 <= length(line) && (push!(ends, runend + 1))
        return replacecharat(ends, GOOD, line)
    end

    function parseinput(test::Bool)
        return map(line -> Nonogram(line), AocUtils.eachinputlines(YEAR, DAY, test))
    end

end