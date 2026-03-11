local M = {}

local cached = nil

--- Returns true if there is currently a cached coverage report.
M.is_cached = function()
    return cached ~= nil
end

--- Returns the cached coverage report or nil.
M.get = function()
    return cached
end

--- Sets the cached coverage report.
--- @param data CoverageData
M.set = function(data)
    cached = data
end

--- Clears any cached report.
M.clear = function()
    cached = nil
end

return M
