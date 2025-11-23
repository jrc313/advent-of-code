module Aoc

    using BenchmarkTools, Suppressor, PrettyTables, ProgressMeter, ProfileView
    export runalldays, runday, benchday, benchalldays, profileday, testday

    const BENCH_SAMPLES = 1000
    const PROFILE_ITERATIONS = 50

    function getdirs(path::String)
        return filter(s -> isdir("$path/$s"), readdir(path))
    end

    function getdays()
        years = Dict{Int, Vector{Int}}()
        for yearstr in getdirs(".")
            if tryparse(Int, yearstr) !== nothing
                year = parse(Int, yearstr)
                years[year] = sort([parse(Int, daystr) for daystr in getdirs("./$yearstr") if tryparse(Int, daystr) !== nothing])
            end
        end
        return years
    end
    YEARDAYS = getdays()

    function runday(year, day, test = false)
        rundays(year, day:day, false, test)
    end

    function testday(year, day)
        runday(year, day, true)
    end

    function benchday(year, day)
        dynloadday(year, day)
        runbench(year, day)
    end

    function profileday(year, day, test = false)
        runprofile(year, day, test)
    end

    function benchalldays(year)
        runalldays(year, true)
    end

    function runalldays(year, benchmark = false)
        if !haskey(YEARDAYS, year)
            println("Nothing in that year")
            return
        end
        @time rundays(year, YEARDAYS[year], benchmark)
    end

    function rundays(year, days, benchmark = false, test = false)
        results = Matrix(undef, 0, benchmark ? 6 : 3)

        pm = Progress(length(days), 0.1, "Running days $(first(days)) to $(last(days))")
        benchmetrics = Matrix(undef, 0, 3)
        for day in days
            dynloadday(year, day)
            p1, p2 = dynrunday(year, day, test)
            row = [day p1 p2]
            if benchmark
                bench = runbench(year, day, test)
                row = hcat(row, benchmarktorow(bench))
                benchmetrics = [benchmetrics; benchmarkmetrics(bench)]
            end

            results = [results; row]

            next!(pm)
        end

        header = ["Day", "Part 1", "Part 2"]
        highlighters::Vector{TextHighlighter} = []
        if benchmark
            append!(header, ["Time (med)", "Memory", "Allocs"])
            totals = summarybenchrow(benchmetrics, sum, "Total")
            #medians = summarybenchrow(benchmetrics, median, "Median")
            results = [results; totals]#; medians]
            
            numrows = size(results, 1)
            #totalrownum, medianrownum = numrows - 1, numrows
            totalrownum = numrows
            totalhl = TextHighlighter((data, i, j) -> i == totalrownum, crayon"cyan")
            #medianhl = Highlighter((data, i, j) -> i == medianrownum, crayon"magenta")

            append!(highlighters, [totalhl])#, medianhl)
        end
        tf = TextTableFormat(; @text__all_horizontal_lines())
        pretty_table(results; column_labels = header, line_breaks = true, alignment = :l, highlighters = highlighters, backend = :text, table_format = tf, fit_table_in_display_vertically = false, maximum_number_of_rows = -1)
    end

    function runprofile(year, day, test = false)
        dynloadday(year, day)
        # Run once to force compilation
        dynrunday(year, day, test)
        @profview [dynrunday(year, day, test) for _ in 1:PROFILE_ITERATIONS]
    end

    function runbench(year, day, test = false)
        # Run once to force compilation
        dynrunday(year, day, test)
        return @benchmark dynrunday($year, $day, $test) samples = BENCH_SAMPLES
    end

    function dynloadday(year, day)
        @suppress include("$(year)/$(lpad(day, 2, "0"))/solution.jl")
    end

    function dynrunday(year, day, test = false)
        return eval(Meta.parse("Aoc$(year)$(lpad(day, 2, "0")).$(test ? "test" : "solve")()"))
    end

    function benchmarkmetrics(b)
        return [median(b.times) memory(b) allocs(b)]
    end

    function summarybenchrow(m, f, name)
        tim = BenchmarkTools.prettytime(f(m[:,1]))
        mem = BenchmarkTools.prettymemory(f(m[:,2]))
        alc = Int(f(m[:,3]))
        ["" "" name  tim mem alc]
    end


    function benchmarktorow(b)
        tim = BenchmarkTools.prettytime(median(b.times))
        mem = BenchmarkTools.prettymemory(memory(b))
        alc = allocs(b)

        return [tim mem alc]
    end

    
end