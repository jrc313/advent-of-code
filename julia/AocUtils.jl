module AocUtils

    using Printf

    function getInputFilename(year::Int, day::Int, test::Bool)
        return @sprintf("%d/%02d/%s.txt", year, day, test ? "test" : "input")
    end

    function getInput(year::Int, day::Int, test::Bool)
        open(getInputFilename(year, day, test)) do file
            read(file, String)
        end
    end

end