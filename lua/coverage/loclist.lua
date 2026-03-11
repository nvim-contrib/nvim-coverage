local M = {}

local report = require("coverage.report")

--- Populates the location list for the current window with lines of the given type.
--- @param sign_type? "uncovered"|"partial" Defaults to "uncovered".
M.populate = function(sign_type)
    sign_type = sign_type or "uncovered"

    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
        return
    end

    local data  = report.get()
    local fname = vim.fn.expand("%:p")
    local file  = data.files[fname]

    if file == nil then
        for sf, cov in pairs(data.files) do
            if vim.fn.bufnr(sf, false) == vim.fn.bufnr("%", false) then
                file  = cov
                fname = sf
                break
            end
        end
    end

    if file == nil then
        vim.notify("No coverage data for current file.", vim.log.levels.INFO)
        return
    end

    local lnums = {}
    if sign_type == "partial" then
        for _, entry in ipairs(file.partial_lines or {}) do
            table.insert(lnums, entry[1])
        end
    else
        for _, lnum in ipairs(file.uncovered_lines) do
            table.insert(lnums, lnum)
        end
    end
    table.sort(lnums)

    local bufnr = vim.fn.bufnr(fname, false)
    local items = {}
    for _, lnum in ipairs(lnums) do
        local text = ""
        if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
            text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
        end
        table.insert(items, { filename = fname, lnum = lnum, col = 0, text = text })
    end

    vim.fn.setloclist(0, {}, "r", { title = "Coverage: " .. sign_type, items = items })
    vim.cmd("lopen")
end

return M
