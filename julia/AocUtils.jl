module AocUtils

    import Base:+
    import Base:-
    import Base:*
    using Printf
    using CSV
    using DataFrames

    export Point, Point3d, getinputfilename, getinputlines, loadintmatrix, loadmatrix, manhattandist, getneighbours, getadjacents, showvar,
           GRID_UP, GRID_DOWN, GRID_LEFT, GRID_RIGHT, GRID_NEIGHBOURS, GRID_ADJACENTS,
           POINT_UP, POINT_DOWN, POINT_LEFT, POINT_RIGHT, POINT_NEIGHBOURS, bounds,
           replacecharat

    const GRID_UP::CartesianIndex = CartesianIndex(-1, 0)
    const GRID_DOWN::CartesianIndex = CartesianIndex(1, 0)
    const GRID_LEFT::CartesianIndex = CartesianIndex(0, -1)
    const GRID_RIGHT::CartesianIndex = CartesianIndex(0, 1)
    const GRID_UP_LEFT::CartesianIndex = GRID_UP + GRID_LEFT
    const GRID_UP_RIGHT::CartesianIndex = GRID_UP + GRID_RIGHT
    const GRID_DOWN_LEFT::CartesianIndex = GRID_DOWN + GRID_LEFT
    const GRID_DOWN_RIGHT::CartesianIndex = GRID_DOWN + GRID_RIGHT

    const GRID_NEIGHBOURS::Vector{CartesianIndex} = [GRID_UP, GRID_DOWN, GRID_LEFT, GRID_RIGHT]
    const GRID_ADJACENTS::Vector{CartesianIndex} = [GRID_UP, GRID_DOWN, GRID_LEFT, GRID_RIGHT, GRID_UP_LEFT, GRID_UP_RIGHT, GRID_DOWN_LEFT, GRID_DOWN_RIGHT]

    struct Point{T<:Real}
        x::T
        y::T
    end
    
    const POINT_UP::Point = Point(-1, 0)
    const POINT_DOWN::Point = Point(1, 0)
    const POINT_LEFT::Point = Point(0, -1)
    const POINT_RIGHT::Point = Point(0, 1)

    const POINT_NEIGHBOURS::Vector{Point} = [POINT_UP, POINT_DOWN, POINT_LEFT, POINT_RIGHT]

    struct Point3d{T<:Real}
        x::T
        y::T
        z::T
    end

    Base.show(io::IO, p::Point) = print(io, "($(p.x), $(p.y))")
    Base.show(io::IO, p::Point3d) = print(io, "($(p.x), $(p.y), $(p.z))")
    Base.show(io::IO, c::CartesianIndex) = print(io, "($(c[1]), $(c[2]))")
    Base.:(+)(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
    Base.:(+)(p1::Point3d, p2::Point3d) = Point3d(p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)
    Base.:(-)(p1::Point, p2::Point) = Point(p1.x - p2.x, p1.y - p2.y)
    Base.:(-)(p1::Point3d, p2::Point3d) = Point3d(p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)
    Base.:reverse(p::Point) = Point(p.y, p.x)
    Base.:(*)(p::Point, i::Int) = Point(p.x * i, p.y * i)
    Base.:(*)(i::Int, p::Point) = Point(p.x * i, p.y * i)

    function manhattandist(a::Point, b::Point)
        return abs(a.x - b.x) + abs(a.y - b.y)
    end
    
    function manhattandist(a::Point3d, b::Point3d)
        return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
    end

    function bounds(points::Vector{Point})
        minh::Int = minw::Int = maxh::Int = maxw::Int = 1
        for p in points
            minh = min(minh, p.x)
            minw = min(minw, p.y)
            maxh = max(maxh, p.x)
            maxw = max(maxw, p.y)
        end
        return (Point(minh, minw), Point(maxh, maxw))
    end

    function replacecharat(i::Int, c::Char, s::String)
        sv::Vector{Char} = collect(s)
        sv[i] = c
        return join(sv)
    end

    function replacecharat(iv::Vector{Int}, c::Char, s::String)
        sv::Vector{Char} = collect(s)
        for i in iv
            sv[i] = c
        end
        return join(sv)
    end

    function replacecharat(iv::UnitRange{Int}, c::Char, s::String)
        sv::Vector{Char} = collect(s)
        for i in iv
            sv[i] = c
        end
        return join(sv)
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

    function loadcsv(year::Int, day::Int, test::Bool, delim::String = ",", type::Type = String)
        filename = getinputfilename(year, day, test)
        return CSV.read(filename, DataFrame; header = false, delim = delim, types = type)
    end

    function getneighbours(pos::CartesianIndex, matrixdims::Tuple{Int, Int})
        return filter(n -> matrixdims[1] >= n[1] > 0 && matrixdims[2] >= n[2] > 0, [pos + neighbour for neighbour in GRID_NEIGHBOURS])
    end

    function getadjacents(pos::CartesianIndex, matrixdims::Tuple{Int, Int})
        return filter(n -> matrixdims[1] >= n[1] > 0 && matrixdims[2] >= n[2] > 0, [pos + neighbour for neighbour in GRID_ADJACENTS])
    end

    function getneighbours(pos::Point, matrixdims::Tuple{Int, Int})
        return filter(n -> matrixdims[1] >= n.x > 0 && matrixdims[2] >= n.y > 0, [pos + neighbour for neighbour in POINT_NEIGHBOURS])
    end

    function showvar(v::Any)
        show(stdout, "text/plain", v)
        println()
    end

    function Base.show(m::Matrix{Char})
        [println(join(row)) for row in eachrow(m)]
    end

    function overlap(r1::UnitRange{Int}, r2::UnitRange{Int})
        return r1.start <= r2.stop && r1.stop >= r2.start
    end

end