local M = {}

local util = require("coverage.util")

--- Parses a SimpleCov JSON file into a CoverageData table.
--- SimpleCov JSON format: {coverage: {[fname]: {lines: [...]}}}
--- Line values: nil/vim.NIL = excluded, 0 = missing, >0 = executed.
--- @param path Path
--- @return CoverageData
M.parse = function(path)
    local ok, json_data = pcall(vim.fn.json_decode, path:read())
    if not ok then
        vim.notify("Failed to decode Ruby coverage JSON: " .. tostring(json_data), vim.log.levels.ERROR)
        return { meta = {}, totals = {
            num_statements = 0,
            covered_lines = 0,
            missing_lines = 0,
            excluded_lines = 0,
            percent_covered = 0,
        }, files = {} }
    end

    --- @type table<string, FileCoverage>
    local files = {}

    for fname, cov in pairs(json_data.coverage) do
        local file = util.new_file_meta()
        for linenr, status in ipairs(cov.lines) do
            if status == nil or status == vim.NIL then
                -- excluded line
                file.summary.excluded_lines = file.summary.excluded_lines + 1
                table.insert(file.excluded_lines, linenr)
            elseif status == 0 then
                -- missing line
                table.insert(file.missing_lines, linenr)
                file.summary.missing_lines = file.summary.missing_lines + 1
                file.summary.num_statements = file.summary.num_statements + 1
            else
                -- executed line (status > 0)
                table.insert(file.executed_lines, linenr)
                file.summary.covered_lines = file.summary.covered_lines + 1
                file.summary.num_statements = file.summary.num_statements + 1
            end
        end
        if file.summary.num_statements > 0 then
            file.summary.percent_covered = file.summary.covered_lines / file.summary.num_statements * 100
        else
            file.summary.percent_covered = 100
        end
        files[fname] = file
    end

    --- @type CoverageSummary
    local totals = {
        num_statements = 0,
        covered_lines = 0,
        missing_lines = 0,
        excluded_lines = 0,
    }
    for _, file in pairs(files) do
        totals.num_statements = totals.num_statements + file.summary.num_statements
        totals.covered_lines = totals.covered_lines + file.summary.covered_lines
        totals.missing_lines = totals.missing_lines + file.summary.missing_lines
        totals.excluded_lines = totals.excluded_lines + file.summary.excluded_lines
    end
    if totals.num_statements > 0 then
        totals.percent_covered = totals.covered_lines / totals.num_statements * 100
    else
        totals.percent_covered = 100
    end

    return { meta = {}, totals = totals, files = files }
end

return M
