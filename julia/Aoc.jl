module Aoc

    using BenchmarkTools, Suppressor, PrettyTables, ProgressMeter, ProfileView
    export runalldays, runday, benchday, benchalldays, profileday, testday

    const YEARDAYS = Dict([(2022, 16), (2023, 14), (2024, 5)])
    const BENCH_SAMPLES = 1000
    const PROFILE_ITERATIONS = 50

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
        maxdays = YEARDAYS[year]
        @time rundays(year, 1:maxdays, benchmark)
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
        highlighters = ()
        if benchmark
            append!(header, ["Time (med)", "Memory", "Allocs"])
            totals = summarybenchrow(benchmetrics, sum, "Total")
            #medians = summarybenchrow(benchmetrics, median, "Median")
            results = [results; totals]#; medians]
            
            numrows = size(results, 1)
            #totalrownum, medianrownum = numrows - 1, numrows
            totalrownum = numrows
            totalhl = Highlighter((data, i, j) -> i == totalrownum, crayon"cyan")
            #medianhl = Highlighter((data, i, j) -> i == medianrownum, crayon"magenta")

            highlighters = (totalhl)#, medianhl)
        end
        pretty_table(results; header = header, linebreaks = true, alignment = :l, hlines = :all, highlighters = highlighters)
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