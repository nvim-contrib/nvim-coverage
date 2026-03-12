local M = {}

local report = require("coverage.cache")

local float_win = nil
local float_bufnr = nil
local autocmd_id = nil

--- Closes the floating window if open.
local close_float = function()
    if float_win ~= nil and vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_win_close(float_win, true)
    end
    float_win = nil
    float_bufnr = nil
end

--- Renders the overlay for the given line and branches.
--- @param lnum integer
--- @param branches BranchInfo[]
local show_for_line = function(lnum, branches)
    close_float()

    local lines = { string.format(" Branch coverage — line %d ", lnum), "" }
    for i, b in ipairs(branches) do
        local status
        if b.count == -1 then
            status = "?  no data"
        elseif b.count == 0 then
            status = "✗  not taken"
        else
            status = string.format("✓  taken (%d×)", b.count)
        end
        table.insert(lines, string.format("  branch %d  %s", i - 1, status))
    end

    float_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(float_bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(float_bufnr, "filetype", "coverage-overlay")

    local width = 30
    for _, l in ipairs(lines) do
        width = math.max(width, #l + 2)
    end

    -- position above cursor when space allows, otherwise below
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    local above = cursor_row - 1 >= #lines + 1

    float_win = vim.api.nvim_open_win(float_bufnr, false, {
        relative = "cursor",
        anchor = above and "SW" or "NW",
        row = above and 0 or 1,
        col = 0,
        width = width,
        height = #lines,
        style = "minimal",
        border = "rounded",
    })

    vim.api.nvim_win_set_option(
        float_win,
        "winhl",
        "Normal:CoverageReportNormal,FloatBorder:CoverageReportBorder"
    )

    -- highlight header
    vim.api.nvim_buf_add_highlight(float_bufnr, -1, "CoverageReportHeader", 0, 0, -1)

    -- highlight individual branch lines
    for i, b in ipairs(branches) do
        local hl = b.count > 0 and "CoverageCovered" or (b.count == 0 and "CoverageUncovered" or "CoveragePartial")
        vim.api.nvim_buf_add_highlight(float_bufnr, -1, hl, i + 1, 0, -1)
    end
end

--- Checks current cursor line and updates the overlay accordingly.
local on_cursor_moved = function()
    if not report.is_cached() then
        close_float()
        return
    end

    local fname = vim.fn.expand("%:p")
    local data = report.get()
    local file = data.files[fname]
    if file == nil then
        -- fallback: match by buffer number the same way signs.build does
        for sf, cov in pairs(data.files) do
            if vim.fn.bufnr(sf, false) == vim.fn.bufnr("%", false) then
                file = cov
                break
            end
        end
    end
    if file == nil then
        close_float()
        return
    end

    local lnum = vim.fn.line(".")
    local branches = file.branches[lnum]
    if branches == nil then
        close_float()
        return
    end

    -- only show when the line has at least one untaken branch
    local has_untaken = false
    for _, b in ipairs(branches) do
        if b.count == 0 then
            has_untaken = true
            break
        end
    end

    if not has_untaken then
        close_float()
        return
    end

    show_for_line(lnum, branches)
end

--- Enables the branch overlay — shows on CursorMoved for partial lines.
M.enable = function()
    if autocmd_id ~= nil then return end
    autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        desc = "nvim-coverage branch overlay",
        callback = on_cursor_moved,
    })
    on_cursor_moved()
end

--- Disables the branch overlay and closes any open float.
M.disable = function()
    if autocmd_id ~= nil then
        vim.api.nvim_del_autocmd(autocmd_id)
        autocmd_id = nil
    end
    close_float()
end

--- Returns true if the branch overlay is currently active.
M.is_enabled = function()
    return autocmd_id ~= nil
end

return M
