local M = {}

local config = require("coverage.config")

local ns_id = nil
local enabled = false

local function get_ns()
	if ns_id == nil then
		ns_id = vim.api.nvim_create_namespace("coverage_line_hits")
	end
	return ns_id
end

--- Places virtual text hit counts for all open buffers in data.
--- Clears any existing extmarks first to avoid duplication on reload.
--- @param data CoverageData
M.place = function(data)
	M.clear()
	local vt = config.opts.line_hits
	for fname, cov in pairs(data.files) do
		local bufnr = vim.fn.bufnr(fname, false)
		if bufnr ~= -1 and cov.hit_counts ~= nil then
			local line_count = vim.api.nvim_buf_line_count(bufnr)
			for lnum, count in pairs(cov.hit_counts) do
				local line = lnum - 1
				if line >= 0 and line < line_count then
					vim.api.nvim_buf_set_extmark(bufnr, get_ns(), line, 0, {
						virt_text = { { string.format("× %d", count), "CoverageLineHits" } },
						virt_text_pos = vt.position,
					})
				end
			end
		end
	end
	enabled = true
end

--- Clears all virtual text extmarks placed by this module.
M.clear = function()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_clear_namespace(bufnr, get_ns(), 0, -1)
		end
	end
	enabled = false
end

--- Returns true if virtual text is currently shown.
M.is_enabled = function()
	return enabled
end

return M
