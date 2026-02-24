local M = {}
local Path = require("plenary.path")

--- Safely decode JSON and call the callback with decoded data.
-- @param data to decode
-- @param callback to call on decode success
M.safe_decode = function(data, callback)
    local ok, json_data = pcall(vim.fn.json_decode, data)
    if ok then
        callback(json_data)
    else
        vim.notify("Failed to decode JSON coverage data: " .. json_data, vim.log.levels.ERROR)
    end
end

--- Chain two functions together.
-- @param a first method to chain
-- @param b second method to chain
-- @return chained method
M.chain = function(a, b)
    return function(...)
        a(b(...))
    end
end

--- Returns a table containing file parameters.
--- @return FileCoverage
M.new_file_meta = function()
    return {
        summary = {
            covered_lines = 0,
            excluded_lines = 0,
            missing_lines = 0,
            num_statements = 0,
            percent_covered = 0,
        },
        missing_lines = {},
        missing_branches = {},
        executed_lines = {},
        excluded_lines = {},
        --- @type table<integer,integer>|nil optional map of line number → hit count
        hit_counts = {},
    }
end

--- Parses a generic report into a files table.
--- @param path Path
--- @param parser fun(path:Path, files:table<string, FileCoverage>)
--- @return CoverageData
M.report_to_table = function(path, parser)
    --- @type table<string, FileCoverage>
    local files = {}

    parser(path, files)

    --- @type CoverageSummary
    local totals = {
        num_statements = 0,
        covered_lines = 0,
        missing_lines = 0,
        excluded_lines = 0,
    }
    for _, meta in pairs(files) do
        totals.num_statements = totals.num_statements + meta.summary.num_statements
        totals.covered_lines = totals.covered_lines + meta.summary.covered_lines
        totals.missing_lines = totals.missing_lines + meta.summary.missing_lines
        totals.excluded_lines = totals.excluded_lines + meta.summary.excluded_lines
    end
    totals.percent_covered = totals.covered_lines / totals.num_statements * 100

    return { meta = {}, totals = totals, files = files }
end

--- Parses a lcov files into a table,
--- see http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php for spec
--- @param path Path
--- @deprecated Use require("coverage.parsers.lcov").parse(path) instead
M.lcov_to_table = function(path)
    return require("coverage.parsers.lcov").parse(path)
end

--- Parses a cobertura file into a table,
--- @param path Path
--- @param path_mappings table<string, string>|nil
--- @deprecated Use require("coverage.parsers.cobertura").parse(path, path_mappings) instead
M.cobertura_to_table = function(path, path_mappings)
    return require("coverage.parsers.cobertura").parse(path, path_mappings)
end

--- Get the coverage file
--- In case the config offers a function, this is called,
--- if it is a list, it tries all files, till one is found
--- in case of a single file, just return it.
M.get_coverage_file = function(file_configuration)
  if type(file_configuration) == 'function' then
    return file_configuration()
  elseif type(file_configuration) == 'table' then
     for _,v in ipairs(file_configuration) do
       if Path:new(v):exists() then
         return v
       end
     end
  else
    return file_configuration
  end
end

return M
