module AocUtils

    using Printf

    export Point, Point3d, getinputfilename, getinputlines, loadintmatrix, manhattandist

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

end