local M = {}

local config = require("coverage.config")

--- @class Highlight
--- @field fg string
--- @field bg string
--- @field sp string
--- @field style string
--- @field link? string

--- @param group string name of the highlight group
--- @param color Highlight
local highlight = function(group, color)
	local style = color.style and "gui=" .. color.style or "gui=NONE"
	local fg = color.fg and "guifg=" .. color.fg or "guifg=NONE"
	local bg = color.bg and "guibg=" .. color.bg or "guibg=NONE"
	local sp = color.sp and "guisp=" .. color.sp or ""
	local hl = "highlight default " .. group .. " " .. style .. " " .. fg .. " " .. bg .. " " .. sp
	vim.cmd(hl)
	if color.link then
		vim.cmd("highlight default link " .. group .. " " .. color.link)
	end
end

local create_highlight_groups = function()
	highlight("CoverageCovered", config.opts.highlights.covered)
	highlight("CoverageUncovered", config.opts.highlights.uncovered)
	highlight("CoveragePartial", config.opts.highlights.partial)
	highlight("CoverageSummaryBorder", config.opts.highlights.summary_border)
	highlight("CoverageSummaryNormal", config.opts.highlights.summary_normal)
	highlight("CoverageSummaryCursorLine", config.opts.highlights.summary_cursor_line)
	highlight("CoverageSummaryPass", config.opts.highlights.summary_pass)
	highlight("CoverageSummaryFail", config.opts.highlights.summary_fail)
	highlight("CoverageSummaryHeader", config.opts.highlights.summary_header)
end

-- Creates default highlight groups.
local autocmd = nil
M.setup = function()
	create_highlight_groups()
	if autocmd == nil then
		autocmd = vim.api.nvim_create_autocmd("ColorScheme", {
			desc = "Add nvim-coverage highlights on colorscheme change",
			callback = create_highlight_groups,
		})
	end
end

return M
