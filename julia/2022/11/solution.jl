module Aoc202211

    const YEAR::Int = 2022
    const DAY::Int = 11

    export solve

    include("../../AocUtils.jl")
    import .AocUtils

    function test()
        return solve(true)
    end

    function solve()
        return solve(false)
    end

    function solve(test::Bool)

        worrymod, monkeys = parseinput(test)
        
        part1 = monkeyaround(deepcopy(monkeys), 20)
        part2 = monkeyaround(deepcopy(monkeys), 10000, false, worrymod)

        return (part1, part2)
    end

    const RELIEF_AMOUNT::Int = 3

    struct monkey
        bag::Vector{Int}
        inspectfn::Function
        throwfn::Function
    end

    function monkeyaround(monkeys::Vector{monkey}, times::Int, hasrelief::Bool = true, worrymod::Int = 1)
        activity::Vector{Int} = fill(0, length(monkeys))
        for i in 1:times
            for (i, m) in enumerate(monkeys)
                activity[i] += length(m.bag)
                for item in m.bag
                    worry = m.inspectfn(item)
                    worry = hasrelief ? worry ÷ RELIEF_AMOUNT : worry % worrymod
                    throwto = m.throwfn(worry)
                    push!(monkeys[throwto].bag, worry)
                end
                empty!(m.bag)
            end
        end

        return reduce(*, partialsort!(activity, 1:2, rev = true))
    end

    function makeinspectfn(opstr::Char, argstr::AbstractString)
        op::Function = opstr === '*' ? (*) : (+)
        arg::Union{Int, Nothing} = tryparse(Int, argstr)

        return worry::Int -> op(worry, arg === nothing ? worry : arg)
    end

    function makethrowfn(divisorstr::AbstractString, throwtstr::Char, throwfstr::Char)
        divisor::Int = parse(Int, divisorstr)
        throwt::Int = parse(Int, throwtstr) + 1
        throwf::Int = parse(Int, throwfstr) + 1

        return (divisor, worry::Int -> worry % divisor === 0 ? throwt : throwf)
    end

    function parseinput(test::Bool)
        filename::String = AocUtils.getinputfilename(YEAR, DAY, test)
        input::Vector{String} = readlines(filename)
        monkeys::Vector{monkey} = Vector{monkey}()
        worrymod::Int = 1

        for i in 1:7:length(input)
            bag::Vector{Int} = [parse(Int, s) for s in eachsplit(input[i+1][19:end], ", ")]
            inspectfn::Function = makeinspectfn(input[i+2][24], input[i+2][26:end])
            divisor::Int, throwfn::Function = makethrowfn(input[i+3][22:end], input[i+4][30], input[i+5][31])
            worrymod *= divisor

            push!(monkeys, monkey(bag, inspectfn, throwfn))
        end

        return (worrymod, monkeys)
    end

end