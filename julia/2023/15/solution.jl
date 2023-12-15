module Aoc202315

    const YEAR::Int = 2023
    const DAY::Int = 15

    export solve

    include("../../AocUtils.jl")
    using .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    struct Lens
        label::String
        length::Int
    end

    Base.show(io::IO, l::Lens) = print(io, "$(l.label)=$(l.length)")

    function solve(test::Bool)
        return parseinput(test)
    end

    function getfocuspower(boxes::Vector{Vector{Lens}})
        focuspower::Int = 0
        for (boxnum, box) in enumerate(boxes)
            for (slot, lens) in enumerate(box)
                focuspower += boxnum * slot * lens.length
            end
        end
        return focuspower
    end

    function gethash(s::String, start::Int = 0)
        return reduce((tally, c) -> ((tally + Int(c)) * 17) % 256, s, init = start)
    end

    function parseinput(test::Bool)
        input::String = AocUtils.getinput(YEAR, DAY, test)
        seqsum::Int = 0
        boxes::Vector{Vector{Lens}} = fill([], 256)
        for op in split(input, ',')
            isremove::Bool = op[end] == '-'
            labelend::Int = (isremove ? 1 : 2)
            label::String = op[1:end-labelend]
            boxnum::Int = gethash(label) + 1
            lenspos::Union{Int, Nothing} = findfirst(l -> l.label == label, boxes[boxnum])
            if isremove
                !isnothing(lenspos) && popat!(boxes[boxnum], lenspos)
            else
                lens::Lens = Lens(label, parse(Int, op[end:end]))
                if isnothing(lenspos)
                    push!(boxes[boxnum], lens)
                else
                    boxes[boxnum][lenspos] = lens
                end
            end
            seqsum += gethash(String(op[end-labelend:end]), boxnum)
        end

        return seqsum, getfocuspower(boxes)
    end

end