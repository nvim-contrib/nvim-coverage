local M = {}

-- neotest.lib.xml is an optional dependency (requires neotest to be installed)
local lom = require("neotest.lib.xml")
local Path = require("plenary.path")
local util = require("coverage.util")

local get_attr_by_type_name = function(tag, type_name)
    if not tag then
        return nil
    end
    for _, value in ipairs(tag) do
        if value._attr.type == type_name then
            return value._attr
        end
    end
    return nil
end

--- Parses a JaCoCo XML report into a CoverageData table.
--- @param path Path
--- @param dir_prefix string directory prefix for resolving source file paths
--- @return CoverageData
M.parse = function(path, dir_prefix)
    local jacoco = lom.parse(table.concat(vim.fn.readfile(path.filename), ""))

    if not jacoco then
        vim.notify("Error loading XML", vim.log.levels.ERROR)
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

    -- Initialize file entries from class definitions
    local packages = assert(jacoco.report.package, "not able to read jacoco.report.package")
    assert(type(packages) == "table")

    for _, pack in ipairs(packages) do
        local dir = dir_prefix .. pack._attr.name

        -- Process sourcefile lines for actual line coverage data
        for _, src_file in ipairs(pack.sourcefile) do
            local filename = Path:new(dir .. "/" .. src_file._attr.name).filename

            if not files[filename] then
                files[filename] = util.new_file_meta()
            end

            local lines = src_file.line
            if lines then
                for _, line in ipairs(lines) do
                    local line_number = assert(tonumber(line._attr.nr))

                    local mb = assert(line._attr.mb) ~= "0"
                    local mi = assert(line._attr.mi) ~= "0"
                    local cb = assert(line._attr.cb) ~= "0"
                    local ci = assert(line._attr.ci) ~= "0"

                    local file = files[filename]
                    if mb and cb or mi and ci then
                        -- partial: executed but has missing branches
                        table.insert(file.executed_lines, line_number)
                        table.insert(file.missing_branches, { line_number, -1 })
                        file.summary.covered_lines = file.summary.covered_lines + 1
                    elseif mb or mi then
                        -- missed
                        table.insert(file.missing_lines, line_number)
                        file.summary.missing_lines = file.summary.missing_lines + 1
                    else
                        -- covered
                        table.insert(file.executed_lines, line_number)
                        file.summary.covered_lines = file.summary.covered_lines + 1
                    end
                    file.summary.num_statements = file.summary.num_statements + 1
                end
            end
        end
    end

    -- Calculate per-file percent_covered and build totals
    local totals = {
        num_statements = 0,
        covered_lines = 0,
        missing_lines = 0,
        excluded_lines = 0,
    }

    for _, file in pairs(files) do
        file.summary.excluded_lines = 0
        if file.summary.num_statements > 0 then
            file.summary.percent_covered = file.summary.covered_lines / file.summary.num_statements * 100
        else
            file.summary.percent_covered = 100
        end
        totals.num_statements = totals.num_statements + file.summary.num_statements
        totals.covered_lines = totals.covered_lines + file.summary.covered_lines
        totals.missing_lines = totals.missing_lines + file.summary.missing_lines
    end

    if totals.num_statements > 0 then
        totals.percent_covered = totals.covered_lines / totals.num_statements * 100
    else
        totals.percent_covered = 100
    end

    -- Also read global branch totals from report-level counters
    local counter = jacoco.report.counter
    if counter then
        local branch = get_attr_by_type_name(counter, "BRANCH")
        if branch then
            totals.num_branches = tonumber(branch.covered) + tonumber(branch.missed)
            totals.num_partial_branches = tonumber(branch.missed)
        end
    end

    return { meta = {}, totals = totals, files = files }
end

return M
