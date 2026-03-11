local M = {}
local Path = require("plenary.path")

--- @class FileCoverage
--- @field excluded_lines integer[]
--- @field covered_lines integer[]
--- @field uncovered_lines integer[]
--- @field partial_lines integer[][]|nil
--- @field hit_counts table<integer, integer> map of line number to execution count
--- @field summary CoverageSummary

--- @class CoverageSummary
--- @field covered_lines integer
--- @field uncovered_lines integer
--- @field excluded_lines integer
--- @field num_branches integer
--- @field num_partial_branches integer
--- @field num_statements integer
--- @field percent_covered number

--- @class CoverageData
--- @field files table<string, FileCoverage>
--- @field totals CoverageSummary

local new_file_meta = function()
    return {
        summary = {
            covered_lines = 0,
            excluded_lines = 0,
            uncovered_lines = 0,
            num_statements = 0,
            percent_covered = 0,
        },
        uncovered_lines = {},
        partial_lines = {},
        covered_lines = {},
        excluded_lines = {},
        hit_counts = {},
    }
end

--- Parses an lcov report from path into a CoverageData table.
--- See http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php for spec.
--- @param path Path
--- @return CoverageData
M.lcov_to_table = function(path)
    local files = {}
    local cfile = nil
    local cmeta = nil

    for _, line in ipairs(path:readlines()) do
        if line:match("end_of_record") and cmeta ~= nil and cfile ~= nil then
            cmeta.summary.excluded_lines = 0
            cmeta.summary.percent_covered = cmeta.summary.covered_lines / cmeta.summary.num_statements * 100
            files[cfile] = cmeta
            cfile = nil
            cmeta = nil
        elseif line:match("SF:.+") then
            -- SF:<absolute path to the source file>
            cfile = line:gsub("SF:", "")
            cmeta = new_file_meta()
        elseif line:match("^DA:%d+,%d+,?.*") and cmeta ~= nil then
            -- DA:<line number>,<execution count>[,<checksum>]
            local ls, ns = line:match("DA:(%d+),(%d+),?.*")
            local l, n = tonumber(ls, 10), tonumber(ns, 10)
            cmeta.hit_counts[l] = n
            if n > 0 then
                table.insert(cmeta.covered_lines, l)
            else
                table.insert(cmeta.uncovered_lines, l)
                cmeta.summary.uncovered_lines = cmeta.summary.uncovered_lines + 1
            end
        elseif line:match("^BRDA:%d+,%d+,%d+,(%d+|-)") and cmeta ~= nil then
            -- BRDA:<line number>,<block number>,<branch number>,<taken>
            local ls, ns = line:match("^BRDA:(%d+),%d+,%d+,(%d+|-)")
            local l = tonumber(ls, 10)
            local n = ns ~= '-' and tonumber(ns, 10) or 0
            if n == 0 then
                table.insert(cmeta.partial_lines, { l, -1 })
            end
        elseif line:match("^BRF:%d+") and cmeta ~= nil then
            -- BRF:<number of branches found>
            cmeta.summary.num_branches = tonumber(line:gsub("BRF:", ""), 10)
        elseif line:match("^BRH:%d+") and cmeta ~= nil then
            -- BRH:<number of branches hit>
            if cmeta.summary.num_branches ~= nil then
                local brh = tonumber(line:gsub("BRH:", ""), 10)
                cmeta.summary.num_partial_branches = cmeta.summary.num_branches - brh
            end
        elseif line:match("LH:%d+") and cmeta ~= nil then
            -- LH:<number of lines with a non-zero execution count>
            cmeta.summary.covered_lines = tonumber(line:gsub("LH:", ""), 10)
        elseif line:match("LF:%d+") and cmeta ~= nil then
            -- LF:<number of instrumented lines>
            cmeta.summary.num_statements = tonumber(line:gsub("LF:", ""), 10)
        end
    end

    local totals = { num_statements = 0, covered_lines = 0, uncovered_lines = 0, excluded_lines = 0 }
    for _, meta in pairs(files) do
        totals.num_statements = totals.num_statements + meta.summary.num_statements
        totals.covered_lines  = totals.covered_lines  + meta.summary.covered_lines
        totals.uncovered_lines  = totals.uncovered_lines  + meta.summary.uncovered_lines
        totals.excluded_lines = totals.excluded_lines + meta.summary.excluded_lines
    end
    totals.percent_covered = totals.covered_lines / totals.num_statements * 100

    return { meta = {}, totals = totals, files = files }
end

return M
