module AocUtils

    using Printf

    function getInputFilename(year::Int, day::Int, test::Bool)
        return @sprintf("%d/%02d/%s.txt", year, day, test ? "test" : "input")
    end

    function getInput(year::Int, day::Int, test::Bool)
        open(getInputFilename(year, day, test)) do file
            readchomp(file)
        end
    end

    function loadintmatrix(year::Int, day::Int, test::Bool)
        filename = getInputFilename(year, day, test)
        return reduce(vcat, [[Int(c) - 48 for c in line]' for line in eachline(filename)])
    end

end