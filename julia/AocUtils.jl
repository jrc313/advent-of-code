module AocUtils

    using Printf

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

end