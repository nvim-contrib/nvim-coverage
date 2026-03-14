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
	if color.link then
		vim.api.nvim_set_hl(0, group, { link = color.link, default = true })
		return
	end
	local opts = { default = true }
	if color.fg then
		opts.fg = color.fg
	end
	if color.bg then
		opts.bg = color.bg
	end
	if color.sp then
		opts.sp = color.sp
	end
	if color.style then
		for attr in color.style:gmatch("[^,]+") do
			opts[attr] = true
		end
	end
	vim.api.nvim_set_hl(0, group, opts)
end

local create_highlight_groups = function()
	highlight("CoverageCovered", config.opts.highlights.covered)
	highlight("CoverageUncovered", config.opts.highlights.uncovered)
	highlight("CoveragePartial", config.opts.highlights.partial)
	highlight("CoverageReportBorder", config.opts.report.highlights.border)
	highlight("CoverageReportNormal", config.opts.report.highlights.normal)
	highlight("CoverageReportCursorLine", config.opts.report.highlights.cursor_line)
	highlight("CoverageReportPass", config.opts.report.highlights.pass)
	highlight("CoverageReportFail", config.opts.report.highlights.fail)
	highlight("CoverageReportHeader", config.opts.report.highlights.header)
	highlight("CoverageLineHits", config.opts.line_hits.highlight)
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
