local M = {}

local cached = nil
local loaded_file = nil

--- Returns true if there is currently a cached coverage report.
M.is_cached = function()
    return cached ~= nil
end

--- Returns the cached coverage report or nil.
M.get = function()
    return cached
end

--- Returns the path of the currently loaded lcov file, or nil.
M.get_file = function()
    return loaded_file
end

--- Sets the cached coverage report.
--- @param data CoverageData
--- @param file string path to the lcov file
M.set = function(data, file)
    cached = data
    loaded_file = file
end

--- Clears any cached report.
M.clear = function()
    cached = nil
    loaded_file = nil
end

return M
