module Aoc202215

    const YEAR::Int = 2022
    const DAY::Int = 15

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    struct Sensor
        pos::Point
        range::Int
    end

    Base.show(io::IO, s::Sensor) = print(io, "Sensor: Pos $(s.pos), Range $(s.range)")

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        sensors, beacons = parseinput(test)

        part1 = countnotbeaconsinrow(sensors, beacons, test ? 10 : 2000000)
        part2 = findholeinsensors(sensors, test ? (1:20) : (1:4000000), test ? 20 : 4000000)

        return (part1, part2)
    end

    function iscontiguousrange(ranges::Vector{Tuple{Int, Int}}, maxallowed::Int)
        length(ranges) < 2 && (return true)
        sort!(ranges, by = r -> r[1])
        maxrng = ranges[1][2]
        for rng in ranges[2:end]
            (maxrng + 1) < rng[1] && return false, maxrng + 1
            maxrng < rng[2] && (maxrng = rng[2])
            maxrng > maxallowed && return true, 0
        end

        return true, 0
    end

    function findholeinsensors(sensors::Vector{Sensor}, bounds::UnitRange{Int}, maxallowed::Int)
        lk = ReentrantLock()
        result::Int = 0
        Threads.@threads for row in bounds
            result != 0 && break
            validsensors = filter(s -> row - s.range <= s.pos.y <= row + s.range, sensors)
            sensorranges = map(s -> sensorrangeatrow(s, row), validsensors)
            contiguous, holecolumn = iscontiguousrange(sensorranges, maxallowed)
            if !contiguous
                lock(lk) do
                    result = (holecolumn * 4000000) + row
                end
            end
        end
        return result
    end

    function sensorrangeatrow(sensor::Sensor, row::Int)
        span::Int = sensor.range - abs(sensor.pos.y - row)
        return (sensor.pos.x - span, sensor.pos.x + span)
    end

    function countnotbeaconsinrow(sensors::Vector{Sensor}, beacons::Vector{Point}, row::Int)
        validsensors = filter(s -> row - s.range <= s.pos.y <= row + s.range, sensors)
        
        sensorranges = map(s -> sensorrangeatrow(s, row), validsensors)
        rngmin = minimum(map(r -> r[1], sensorranges))
        rngmax = maximum(map(r -> r[2], sensorranges))
        sensorrng = rngmin:rngmax
        beaconsinrow = length(filter(b -> b.y == row && b.y ∈ sensorrng, beacons))

        return length(sensorrng) - beaconsinrow
    end

    function parseinput(test::Bool)
        filename = getinputfilename(YEAR, DAY, test)
        sensors = Vector{Sensor}()
        beacons = Vector{Point}()
        for line in eachline(filename)
            matches = match(r"^Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)$", line)
            sensorpos = Point(parse(Int, matches[1]), parse(Int, matches[2]))
            beaconpos = Point(parse(Int, matches[3]), parse(Int, matches[4]))
            sensorrange = manhattandist(sensorpos, beaconpos)
            push!(sensors, Sensor(sensorpos, sensorrange))
            push!(beacons, beaconpos)
        end

        return sort(sensors, by = s -> s.pos.x), unique(beacons)
    end

end