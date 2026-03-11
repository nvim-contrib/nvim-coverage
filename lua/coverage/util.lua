local M = {}
local Path = require("plenary.path")

--- @class FileCoverage
--- @field excluded_lines integer[]
--- @field executed_lines integer[]
--- @field missing_lines integer[]
--- @field missing_branches integer[][]|nil
--- @field summary CoverageSummary

--- @class CoverageSummary
--- @field covered_lines integer
--- @field missing_lines integer
--- @field excluded_lines integer
--- @field num_branches integer
--- @field num_partial_branches integer
--- @field num_statements integer
--- @field percent_covered number

--- @class CoverageData
--- @field files table<string, FileCoverage>
--- @field totals CoverageSummary

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
    }
end

--- Parses an lcov report from path into files.
--- @param path Path
--- @param files table<string, FileCoverage>
local lcov_parser = function(path, files)
    local cfile = nil
    local cmeta = nil

    for _, line in ipairs(path:readlines()) do
        if line:match("end_of_record") and cmeta ~= nil and cfile ~= nil then
            cmeta.summary["excluded_lines"] = 0
            cmeta.summary["percent_covered"] = cmeta.summary.covered_lines / cmeta.summary.num_statements * 100
            files[cfile] = cmeta
            cfile = nil
            cmeta = nil
        elseif line:match("SF:.+") then
            -- SF:<absolute path to the source file>
            cfile = line:gsub("SF:", "")
            cmeta = M.new_file_meta()
        elseif line:match("^DA:%d+,%d+,?.*") and cmeta ~= nil then
            -- DA:<line number>,<execution count>[,<checksum>]
            local ls, ns = line:match("DA:(%d+),(%d+),?.*")
            local l, n = tonumber(ls, 10), tonumber(ns, 10)
            if n > 0 then
                table.insert(cmeta.executed_lines, l)
            else
                table.insert(cmeta.missing_lines, l)
                cmeta.summary.missing_lines = cmeta.summary.missing_lines + 1
            end
        elseif line:match("^BRDA:%d+,%d+,%d+,(%d+|-)") and cmeta ~= nil then
            -- BRDA:<line number>,<block number>,<branch number>,<taken>
            local ls, ns = line:match("^BRDA:(%d+),%d+,%d+,(%d+|-)")
            local l = tonumber(ls, 10)
            local n = 0
            if ns ~= '-' then
                n = tonumber(ns, 10)
            end
            if n == 0 then
                table.insert(cmeta.missing_branches, { l, -1 })
            end
        elseif line:match("^BRF:%d+") and cmeta ~= nil then
            -- BRF:<number of branches found>
            local brf = tonumber(line:gsub("BRF:", ""), 10)
            cmeta.summary.num_branches = brf
        elseif line:match("^BRH:%d+") and cmeta ~= nil then
            -- BRH:<number of branches hit>
            if cmeta.summary.num_branches ~= nil then
                local brh = tonumber(line:gsub("BRH:", ""), 10)
                cmeta.summary.num_partial_branches = cmeta.summary.num_branches - brh
            end
        elseif line:match("LH:%d+") and cmeta ~= nil then
            -- LH:<number of lines with a non-zero execution count>
            local lh = tonumber(line:gsub("LH:", ""), 10)
            cmeta.summary["covered_lines"] = lh
        elseif line:match("LF:%d+") and cmeta ~= nil then
            -- LF:<number of instrumented lines>
            local lf = tonumber(line:gsub("LF:", ""), 10)
            cmeta.summary["num_statements"] = lf
        end
    end
end

--- Parses a generic report into a files table.
--- @param path Path
--- @param parser fun(path:Path, files:table<string, FileCoverage>)
--- @return CoverageData
M.report_to_table = function(path, parser)
    local files = {}
    parser(path, files)

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

--- Parses an lcov file into a table.
--- See http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php for spec.
--- @param path Path
M.lcov_to_table = function(path)
    return M.report_to_table(path, lcov_parser)
end

return M
