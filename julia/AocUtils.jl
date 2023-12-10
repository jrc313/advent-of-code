module AocUtils

    using Printf

    export Point, Point3d, getinputfilename, getinputlines, loadintmatrix, loadmatrix, manhattandist, getneighbours,
           GRID_UP, GRID_DOWN, GRID_LEFT, GRID_RIGHT, GRID_NEIGHBOURS

    const GRID_UP::CartesianIndex = CartesianIndex(-1, 0)
    const GRID_DOWN::CartesianIndex = CartesianIndex(1, 0)
    const GRID_LEFT::CartesianIndex = CartesianIndex(0, -1)
    const GRID_RIGHT::CartesianIndex = CartesianIndex(0, 1)

    const GRID_NEIGHBOURS::Vector{CartesianIndex} = [GRID_UP, GRID_DOWN, GRID_LEFT, GRID_RIGHT]


    struct Point
        x::Int
        y::Int
    end

    Base.show(io::IO, p::Point) = print(io, "Point($(p.x), $(p.y))")

    struct Point3d
        x::Int
        y::Int
        z::Int
    end

    Base.show(io::IO, p::Point3d) = print(io, "Point3($(p.x), $(p.y), $(p.z))")

    function manhattandist(a::Point, b::Point)
        return abs(a.x - b.x) + abs(a.y - b.y)
    end

    function manhattandist(a::Point3d, b::Point3d)
        return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
    end

    function getinputfilename(year::Int, day::Int, test::Bool)
        return @sprintf("%d/%02d/%s.txt", year, day, test ? "test" : "input")
    end

    function getinput(year::Int, day::Int, test::Bool)
        open(getinputfilename(year, day, test)) do file
            readchomp(file)
        end
    end

    function getinputlines(year::Int, day::Int, test::Bool)
        return readlines(getinputfilename(year, day, test))
    end

    function eachinputlines(year::Int, day::Int, test::Bool)
        return eachline(getinputfilename(year, day, test))
    end

    function loadintmatrix(year::Int, day::Int, test::Bool)
        loadintmatrix(year, day, test, (c, ind) -> Int(c) - 48)
    end

    function loadintmatrix(year::Int, day::Int, test::Bool, charparsefn::Function)
        filename = getinputfilename(year, day, test)
        return reduce(vcat, [[charparsefn(c, CartesianIndex(row, col)) for (col, c) in enumerate(line)]' for (row, line) in enumerate(eachline(filename))])
    end

    function loadcharmatrix(year::Int, day::Int, test::Bool)
        filename = getinputfilename(year, day, test)
        return reduce(vcat, [permutedims([c for c in line]) for line in eachline(filename)])
    end

    function loadmatrix(year::Int, day::Int, test::Bool, charparsefn::Function)
        filename = getinputfilename(year, day, test)
        return reduce(vcat, [permutedims([charparsefn(c, CartesianIndex(row, col)) for (col, c) in enumerate(line)]) for (row, line) in enumerate(eachline(filename))])
    end

    function getneighbours(pos::CartesianIndex, matrixdims::Tuple{Int, Int})
        return filter(n -> matrixdims[1] >= n[1] > 0 && matrixdims[2] >= n[2] > 0, [pos + neighbour for neighbour in GRID_NEIGHBOURS])
    end

    function showvar(v::Any)
        show(stdout, "text/plain", v)
        println()
    end

    function overlap(r1::UnitRange{Int}, r2::UnitRange{Int})
        return r1.start <= r2.stop && r1.stop >= r2.start
    end

end