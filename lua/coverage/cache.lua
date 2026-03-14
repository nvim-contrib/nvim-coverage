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

--- Finds file coverage by filename, falling back to buffer number matching.
--- @param fname string absolute path to look up
--- @return FileCoverage|nil coverage data for the file
--- @return string|nil matched filename key
M.find_file = function(fname)
	if cached == nil then
		return nil, nil
	end
	local file = cached.files[fname]
	if file ~= nil then
		return file, fname
	end
	for sf, cov in pairs(cached.files) do
		if vim.fn.bufnr(sf, false) == vim.fn.bufnr(fname, false) then
			return cov, sf
		end
	end
	return nil, nil
end

return M
