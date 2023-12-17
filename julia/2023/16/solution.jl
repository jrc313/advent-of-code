module Aoc202316

    const YEAR::Int = 2023
    const DAY::Int = 16

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end
    
    const SPACE::Int = 0
    const UPDOWN::Int = 1
    const LEFTRIGHT::Int = 2
    const DEFLECTRIGHT::Int = 3
    const DEFLECTLEFT::Int = 4
    const CHAR_MAP::Dict{Char, Int} = Dict('.' => SPACE, '|' => UPDOWN, '-' => LEFTRIGHT, '/' => DEFLECTRIGHT, '\\' => DEFLECTLEFT)

    function solve(test::Bool)

        contraption::Matrix{Int} = parseinput(test)

        cols, rows = size(contraption)
        cols = cols - 1
        rows = rows - 1

        energies::Vector{Int} = []
        append!(energies,
            [runcontraption(contraption, c, GRID_RIGHT) for c in CartesianIndex(2, 2):CartesianIndex(rows, 2)],
            [runcontraption(contraption, c, GRID_DOWN) for c in CartesianIndex(2, 2):CartesianIndex(2, cols)],
            [runcontraption(contraption, c, GRID_LEFT) for c in CartesianIndex(2, cols):CartesianIndex(rows, cols)],
            [runcontraption(contraption, c, GRID_UP) for c in CartesianIndex(rows, 2):CartesianIndex(rows, cols)])

        part1 = energies[1]
        part2 = maximum(energies)

        return (part1, part2)
    end

    function deflectbeam(beamdir::Point, deflectdir::Int)::Point
        if deflectdir == DEFLECTLEFT
            beamdir == POINT_UP && return POINT_LEFT
            beamdir == POINT_DOWN && return POINT_RIGHT
            beamdir == POINT_LEFT && return POINT_UP
            beamdir == POINT_RIGHT && return POINT_DOWN
        else
            beamdir == POINT_UP && return POINT_RIGHT
            beamdir == POINT_DOWN && return POINT_LEFT
            beamdir == POINT_LEFT && return POINT_DOWN
            beamdir == POINT_RIGHT && return POINT_UP
        end
    end

    function beamhash(pos::Point, dir::Point)::Int
        return pos.x << 24 + pos.y << 16 + dir.x << 8 + dir.y
    end

    function runcontraption(contraption::Matrix{Int}, startpos::CartesianIndex, startdir::CartesianIndex)::Int
        beammap::Matrix{Bool} = falses(size(contraption))
        activebeams::Vector{Tuple{Point, Point}} = [(Point(startpos[1], startpos[2]), Point(startdir[1], startdir[2]))]
        seenstates::Set{Int} = Set()

        while length(activebeams) > 0
            for (i, beam) in enumerate(activebeams)
                beampos::Point, beamdir::Point = beam
                nodeval::Int = contraption[beampos.x, beampos.y]

                if beamhash(beampos, beamdir) in seenstates || nodeval == -1
                    deleteat!(activebeams, i)
                    continue
                end

                push!(seenstates, beamhash(beampos, beamdir))
                beammap[beampos.x, beampos.y] = true
                
                if nodeval == UPDOWN && (beamdir == POINT_LEFT || beamdir == POINT_RIGHT)
                    activebeams[i] = (add(beampos, POINT_UP), POINT_UP)
                    push!(activebeams, (add(beampos, POINT_DOWN), POINT_DOWN))
                elseif nodeval == LEFTRIGHT && (beamdir == POINT_UP || beamdir == POINT_DOWN)
                    activebeams[i] = (add(beampos, POINT_LEFT), POINT_LEFT)
                    push!(activebeams, (add(beampos, POINT_RIGHT), POINT_RIGHT))
                elseif nodeval == DEFLECTLEFT || nodeval == DEFLECTRIGHT
                    beamdir = deflectbeam(beamdir, nodeval)
                    activebeams[i] = (add(beampos, beamdir), beamdir)
                else
                    activebeams[i] = (add(beampos, beamdir), beamdir)
                end
            end
        end

        return sum(beammap)
    end

    function parseinput(test::Bool)
        m::Matrix{Int} = AocUtils.loadintmatrix(YEAR, DAY, test, (c, pos) -> CHAR_MAP[c])
        h, w = size(m)
        m = vcat(fill(-1, 1, w), m, fill(-1, 1, w))
        m = hcat(fill(-1, h + 2, 1), m, fill(-1, h + 2, 1))
    end

end