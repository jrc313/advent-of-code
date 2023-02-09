module Aoc202208

    const YEAR::Int = 2022
    const DAY::Int = 8

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

        trees = parseinput(test)

        return inspecttrees(trees)
    end

    function inspecttrees(trees::Matrix{Int})
        rows, cols = size(trees)
        visible = falses(rows, cols)
        visible[1, :] .= true
        visible[end, :] .= true
        visible[:, 1] .= true
        visible[:, end] .= true

        maxtreescore = 0

        for i in 2:rows - 1
            maxheights = [trees[i, 1], trees[1, i], trees[i, end], trees[end, i]]
            for j in 2:cols - 1
                invj::Int = rows - j + 1
                setvisibility(trees[i, j], view(visible, CartesianIndex(i, j)), view(maxheights, 1))
                setvisibility(trees[j, i], view(visible, CartesianIndex(j, i)), view(maxheights, 2))
                setvisibility(trees[i, invj], view(visible, CartesianIndex(i, invj)), view(maxheights, 3))
                setvisibility(trees[invj, i], view(visible, CartesianIndex(invj, i)), view(maxheights, 4))

                myheight = trees[i, j]
                treescore = visibleintreeline(myheight, view(trees, i, j + 1:cols)) *
                            visibleintreeline(myheight, reverse(view(trees, i, 1:j - 1))) *
                            visibleintreeline(myheight, view(trees, i + 1:rows, j)) *
                            visibleintreeline(myheight, reverse(view(trees, 1:i - 1, j)))
                treescore > maxtreescore && (maxtreescore = treescore)
            end
        end

        return (visible |> sum, maxtreescore)
    end

    function setvisibility(height::Int, visible::AbstractArray, maxheights::AbstractArray)
        if height > maxheights[1]
            visible[1] = true
            maxheights[1] = height
        end
    end

    function visibleintreeline(height::Int, treeline::AbstractArray)
        visible = length(collect(Iterators.takewhile(h -> h < height, treeline)))
        return visible < length(treeline) ? visible + 1 : visible
    end

    function parseinput(test::Bool)
        return AocUtils.loadintmatrix(YEAR, DAY, test)
    end

end