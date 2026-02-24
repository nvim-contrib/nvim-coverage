local M = {}

local Path = require("plenary.path")
local util = require("coverage.util")

--- Walk Swift coverage segments and populate FileCoverage line/branch data.
--- Segments format: each entry is {line, col, count, has_count, ...}
--- @param segments table
--- @param file FileCoverage
local function walk_segments(segments, file)
    local segment = nil
    local last_sign_line = -1
    local last_sign_covered = nil

    for _, next_segment in ipairs(segments) do
        if segment ~= nil then
            local line, _, count, has_count = unpack(segment)
            if has_count then
                local next_line = next_segment[1]
                local covered = count > 0
                for i = line, next_line do
                    if i == last_sign_line then
                        -- conflict: same line was already classified differently → partial
                        if last_sign_covered ~= nil and last_sign_covered ~= covered then
                            -- remove the last entry from executed_lines and add to missing_branches
                            table.remove(file.executed_lines)
                            table.insert(file.missing_branches, { i, -1 })
                            last_sign_covered = nil
                        end
                    else
                        if covered then
                            table.insert(file.executed_lines, i)
                            file.summary.covered_lines = file.summary.covered_lines + 1
                        else
                            table.insert(file.missing_lines, i)
                            file.summary.missing_lines = file.summary.missing_lines + 1
                        end
                        file.summary.num_statements = file.summary.num_statements + 1
                        last_sign_covered = covered
                    end
                end
                last_sign_line = next_line
            end
        end
        segment = next_segment
    end
end

--- Parse a pre-decoded Swift coverage JSON table into CoverageData.
--- Swift JSON format: {data: [{files: [{filename, segments, summary}], totals: {...}}]}
--- @param data table already-decoded JSON table
--- @return CoverageData
M.parse_table = function(data)
    --- @type table<string, FileCoverage>
    local files = {}

    for _, datum in ipairs(data.data) do
        for _, f in ipairs(datum.files) do
            local fname = Path:new(f.filename):make_relative()
            -- skip build artifacts (relative path starting with .build/ or absolute containing /.build/)
            if fname:match("^%.build/") or f.filename:match("/%.build/") then
                goto next_file
            end

            local file = util.new_file_meta()
            walk_segments(f.segments, file)

            -- Use summary counts from the JSON for accuracy (overrides segment walk counts)
            file.summary.num_statements = f.summary.lines.count
            file.summary.covered_lines = f.summary.lines.covered
            file.summary.missing_lines = f.summary.lines.count - f.summary.lines.covered
            if file.summary.num_statements > 0 then
                file.summary.percent_covered = f.summary.lines.covered / f.summary.lines.count * 100
            else
                file.summary.percent_covered = 100
            end

            files[f.filename] = file
            ::next_file::
        end
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
    end
    if totals.num_statements > 0 then
        totals.percent_covered = totals.covered_lines / totals.num_statements * 100
    else
        totals.percent_covered = 100
    end

    return { meta = {}, totals = totals, files = files }
end

--- Parse a Swift coverage JSON file into CoverageData.
--- @param path Path
--- @return CoverageData
M.parse = function(path)
    local ok, json_data = pcall(vim.fn.json_decode, path:read())
    if not ok then
        vim.notify("Failed to decode Swift coverage JSON: " .. tostring(json_data), vim.log.levels.ERROR)
        return { meta = {}, totals = {
            num_statements = 0,
            covered_lines = 0,
            missing_lines = 0,
            excluded_lines = 0,
            percent_covered = 0,
        }, files = {} }
    end
    return M.parse_table(json_data)
end

return M
