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

    function loadintmatrix(year::Int, day::Int, test::Bool)
        filename = getinputfilename(year, day, test)
        return reduce(vcat, [[Int(c) - 48 for c in line]' for line in eachline(filename)])
    end

end