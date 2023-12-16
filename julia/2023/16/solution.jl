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

        layout::Matrix{Int} = parseinput(test)

        cols, rows = size(layout)

        energies::Vector{Int} = []
        append!(energies, [runcontraption(layout, c, GRID_RIGHT) for c in CartesianIndex(1, 1):CartesianIndex(rows, 1)])
        append!(energies, [runcontraption(layout, c, GRID_DOWN) for c in CartesianIndex(1, 1):CartesianIndex(1, cols)])
        append!(energies, [runcontraption(layout, c, GRID_LEFT) for c in CartesianIndex(1, cols):CartesianIndex(rows, cols)])
        append!(energies, [runcontraption(layout, c, GRID_UP) for c in CartesianIndex(rows, 1):CartesianIndex(rows, cols)])

        part1 = energies[1]
        part2 = maximum(energies)

        return (part1, part2)
    end

    function deflectbeam(beamdir::CartesianIndex, deflectdir::Int)::CartesianIndex
        if deflectdir == DEFLECTLEFT
            beamdir == GRID_UP && return GRID_LEFT
            beamdir == GRID_DOWN && return GRID_RIGHT
            beamdir == GRID_LEFT && return GRID_UP
            beamdir == GRID_RIGHT && return GRID_DOWN
        else
            beamdir == GRID_UP && return GRID_RIGHT
            beamdir == GRID_DOWN && return GRID_LEFT
            beamdir == GRID_LEFT && return GRID_DOWN
            beamdir == GRID_RIGHT && return GRID_UP
        end
    end
    
    function showbeam(beam::Tuple{CartesianIndex, CartesianIndex})
        s::String = "$(beam[1]) "
        beam[2] == GRID_UP && return "$s ^"
        beam[2] == GRID_DOWN && return "$s v"
        beam[2] == GRID_LEFT && return "$s <"
        beam[2] == GRID_RIGHT && return "$s >"
    end

    function inbounds(c::CartesianIndex, w, h)
        return c[1] > 0 && c[1] <= h && c[2] > 0 && c[2] <= w
    end

    function runcontraption(layout::Matrix{Int}, startpos::CartesianIndex, startdir::CartesianIndex)
        h, w = size(layout)
        beammap::Matrix{Bool} = falses(size(layout))
        activebeams::Vector{Tuple{CartesianIndex, CartesianIndex}} = [(startpos, startdir)]
        seenstates::Set{Tuple{CartesianIndex, CartesianIndex}} = Set()
        while length(activebeams) > 0
            for (i, beam) in enumerate(activebeams)
                beampos::CartesianIndex, beamdir::CartesianIndex = beam
                
                if beam in seenstates || !inbounds(beampos, w, h)
                    deleteat!(activebeams, i)
                    continue
                end
                push!(seenstates, beam)
                beammap[beampos] = true
                nodeval::Int = layout[beampos]
                if nodeval == UPDOWN && (beamdir == GRID_LEFT || beamdir == GRID_RIGHT)
                    activebeams[i] = (beampos + GRID_UP, GRID_UP)
                    push!(activebeams, (beampos + GRID_DOWN, GRID_DOWN))
                elseif nodeval == LEFTRIGHT && (beamdir == GRID_UP || beamdir == GRID_DOWN)
                    activebeams[i] = (beampos + GRID_LEFT, GRID_LEFT)
                    push!(activebeams, (beampos + GRID_RIGHT, GRID_RIGHT))
                elseif nodeval == DEFLECTLEFT || nodeval == DEFLECTRIGHT
                    beamdir = deflectbeam(beamdir, nodeval)
                    activebeams[i] = (beampos + beamdir, beamdir)
                else
                    activebeams[i] = (beampos + beamdir, beamdir)
                end
            end
        end

        return sum(beammap)
    end

    function parseinput(test::Bool)
        return AocUtils.loadintmatrix(YEAR, DAY, test, (c, pos) -> CHAR_MAP[c])
    end

end