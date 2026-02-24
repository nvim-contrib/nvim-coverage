local M = {}

local config = require("coverage.config")

local ns_id = vim.api.nvim_create_namespace("coverage_virtual_text")
local enabled = false

--- Returns the virtual text chunks for a covered line.
--- @param hit_count integer|nil number of times the line was executed
--- @return table[] virt_text chunks for nvim_buf_set_extmark
local function covered_vtext(hit_count)
    local vt_config = config.opts.virtual_text
    local text
    if vt_config.annotation == "hits" and hit_count ~= nil then
        text = string.format(" ×%d", hit_count)
    else
        text = vt_config.covered_string or " ✓"
    end
    return { { text, vt_config.covered_hl or "CoverageCovered" } }
end

--- Returns the virtual text chunks for an uncovered line.
--- @return table[] virt_text chunks for nvim_buf_set_extmark
local function uncovered_vtext()
    local vt_config = config.opts.virtual_text
    local text = vt_config.uncovered_string or " ✗"
    return { { text, vt_config.uncovered_hl or "CoverageUncovered" } }
end

--- Returns the virtual text chunks for a partially covered line.
--- @return table[] virt_text chunks for nvim_buf_set_extmark
local function partial_vtext()
    local vt_config = config.opts.virtual_text
    local text = vt_config.partial_string or " ½"
    return { { text, vt_config.partial_hl or "CoveragePartial" } }
end

--- Place virtual text extmarks for all loaded buffers.
--- @param data CoverageData
M.show = function(data)
    M.hide()
    local Path = require("plenary.path")
    for fname, cov in pairs(data.files) do
        local bufnr = vim.fn.bufnr(Path:new(fname):make_relative(), false)
        if bufnr == -1 then
            bufnr = vim.fn.bufnr(fname, false)
        end
        if bufnr == -1 then
            goto continue
        end

        -- Collect partial lines (executed but has missing branch from same line)
        local partial_lines = {}
        if cov.missing_branches then
            for _, branch in ipairs(cov.missing_branches) do
                partial_lines[branch[1]] = true
            end
        end

        -- Executed lines
        for _, lnum in ipairs(cov.executed_lines) do
            local vtext
            if partial_lines[lnum] then
                vtext = partial_vtext()
            else
                local hit_count = cov.hit_counts and cov.hit_counts[lnum]
                vtext = covered_vtext(hit_count)
            end
            pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, lnum - 1, 0, {
                virt_text = vtext,
                virt_text_pos = "eol",
                hl_mode = "combine",
            })
        end

        -- Missing lines
        for _, lnum in ipairs(cov.missing_lines) do
            pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, lnum - 1, 0, {
                virt_text = uncovered_vtext(),
                virt_text_pos = "eol",
                hl_mode = "combine",
            })
        end

        ::continue::
    end
    enabled = true
end

--- Remove all virtual text extmarks.
M.hide = function()
    -- Clear from all buffers that have this namespace
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_id, 0, -1)
        end
    end
    enabled = false
end

--- Toggle virtual text on/off.
--- @param data CoverageData
M.toggle = function(data)
    if enabled then
        M.hide()
    else
        M.show(data)
    end
end

--- Returns true if virtual text is currently shown.
M.is_enabled = function()
    return enabled
end

return M
