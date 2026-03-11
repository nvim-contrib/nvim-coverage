local M = {}

local report = require("coverage.report")

--- Populates the quickfix list with one entry per file showing coverage summary.
--- @param filter? "uncovered" When given, only includes files with uncovered lines.
M.populate = function(filter)
    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
        return
    end

    local data = report.get()
    local rows = {}

    for filename, file in pairs(data.files) do
        local uncovered = #file.uncovered_lines
        local partial   = #(file.partial_lines or {})
        local pct       = file.summary.percent_covered

        if filter == "uncovered" and uncovered == 0 then
            goto continue
        end

        local text
        if pct >= 100 then
            text = "100%"
        else
            local parts = {}
            if uncovered > 0 then table.insert(parts, uncovered .. " uncovered") end
            if partial   > 0 then table.insert(parts, partial   .. " partial")   end
            text = string.format("%.0f%% — %s", pct, table.concat(parts, ", "))
        end

        table.insert(rows, { filename = filename, lnum = 1, col = 0, text = text, pct = pct })

        ::continue::
    end

    -- worst coverage first
    table.sort(rows, function(a, b) return a.pct < b.pct end)

    local items = {}
    for _, row in ipairs(rows) do
        table.insert(items, { filename = row.filename, lnum = row.lnum, col = row.col, text = row.text })
    end

    vim.fn.setqflist({}, "r", { title = "Coverage", items = items })
    vim.cmd("copen")
end

return M
