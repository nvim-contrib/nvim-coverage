local M = {}

local Path = require("plenary.path")
local report = require("coverage.report")

--- Build a quickfix/loclist item list from coverage data.
--- @param data CoverageData
--- @param bufnr_filter integer|nil if set, only include items for this buffer
--- @return table[] list of quickfix items (:h setqflist)
local function build_items(data, bufnr_filter)
    local items = {}
    for fname, cov in pairs(data.files) do
        local bufnr = vim.fn.bufnr(Path:new(fname):make_relative(), false)
        if bufnr_filter ~= nil and bufnr ~= bufnr_filter then
            goto continue
        end
        for _, lnum in ipairs(cov.missing_lines) do
            table.insert(items, {
                filename = fname,
                lnum = lnum,
                col = 0,
                text = "uncovered line",
                type = "W",
                bufnr = bufnr ~= -1 and bufnr or nil,
            })
        end
        for _, branch in ipairs(cov.missing_branches or {}) do
            local lnum = branch[1]
            table.insert(items, {
                filename = fname,
                lnum = lnum,
                col = 0,
                text = "partial branch",
                type = "W",
                bufnr = bufnr ~= -1 and bufnr or nil,
            })
        end
        ::continue::
    end
    -- Sort by filename then line number for a stable order
    table.sort(items, function(a, b)
        if a.filename ~= b.filename then
            return a.filename < b.filename
        end
        return a.lnum < b.lnum
    end)
    return items
end

--- Populate the quickfix list with all uncovered lines across every file in
--- the loaded coverage report.  Opens the quickfix window when done.
M.set_qflist = function()
    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.WARN)
        return
    end
    local items = build_items(report.get())
    vim.fn.setqflist({}, "r", { title = "Coverage: uncovered lines", items = items })
    vim.cmd("copen")
    vim.notify(string.format("Coverage: %d uncovered location(s) added to quickfix list.", #items), vim.log.levels.INFO)
end

--- Populate the location list for the current window with uncovered lines
--- in the current buffer only.  Opens the location list window when done.
M.set_loclist = function()
    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.WARN)
        return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local items = build_items(report.get(), bufnr)
    if #items == 0 then
        -- Try with no buffer filter in case absolute vs relative path mismatch
        items = build_items(report.get())
        -- Now filter by current buffer filename
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local filtered = {}
        for _, item in ipairs(items) do
            if item.filename == fname then
                table.insert(filtered, item)
            end
        end
        items = filtered
    end
    vim.fn.setloclist(0, {}, "r", { title = "Coverage: uncovered lines", items = items })
    vim.cmd("lopen")
    vim.notify(string.format("Coverage: %d uncovered location(s) added to location list.", #items), vim.log.levels.INFO)
end

return M
