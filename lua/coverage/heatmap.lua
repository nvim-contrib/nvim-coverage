--- Text-mode strip treemap showing file coverage as colored blocks in a floating window.
--- Files are sized proportionally to their line count and colored by coverage %.
--- Requires a prior coverage load.

local M = {}

local cache = require("coverage.cache")
local Path = require("plenary.path")

local ns = vim.api.nvim_create_namespace("coverage_heatmap")
local augroup = vim.api.nvim_create_augroup("CoverageHeatmap", { clear = false })
local popup_win = nil
local layout_data = nil -- last computed layout, used for <CR> navigation

-- =============================================================================
-- 1. HIGHLIGHT GROUPS
-- =============================================================================

--- Interpolate between two integer values.
local function lerp(a, b, t)
	return math.floor(a + (b - a) * t + 0.5)
end

--- Convert a coverage percentage to a dark background hex color.
--- 0% = dark red, 50% = dark amber, 100% = dark green.
local function pct_to_bg(pct)
	local r, g, b
	if pct <= 50 then
		local t = pct / 50
		r = lerp(0x5c, 0x5c, t)
		g = lerp(0x10, 0x4a, t)
		b = lerp(0x10, 0x10, t)
	else
		local t = (pct - 50) / 50
		r = lerp(0x5c, 0x1a, t)
		g = lerp(0x4a, 0x5c, t)
		b = lerp(0x10, 0x1a, t)
	end
	return string.format("#%02x%02x%02x", r, g, b)
end

--- Create all heatmap highlight groups. Re-runs on ColorScheme change.
local function create_highlights()
	for i = 0, 20 do
		local pct = i * 5
		local name = "CoverageHeatmap" .. pct
		vim.api.nvim_set_hl(0, name, { bg = pct_to_bg(pct), fg = "#dddddd", default = false })
	end
end

-- Recreate highlight groups whenever the colorscheme changes.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = augroup,
	callback = create_highlights,
})

--- Return the highlight group name for a coverage percentage.
local function hl_for_pct(pct)
	local bucket = math.floor(pct / 5 + 0.5) * 5
	bucket = math.max(0, math.min(100, bucket))
	return "CoverageHeatmap" .. bucket
end

-- =============================================================================
-- 2. LAYOUT (strip treemap)
-- =============================================================================

--- Build a flat list of {filename, statements, pct} from the cached report.
local function build_file_list()
	local data = cache.get()
	local files = {}
	for fname, cov in pairs(data.files) do
		table.insert(files, {
			filename = fname,
			statements = math.max(1, cov.summary.num_statements or 1),
			pct = cov.summary.percent_covered or 0,
		})
	end
	-- Sort largest files first for better strip aspect ratios
	table.sort(files, function(a, b)
		return a.statements > b.statements
	end)
	return files
end

--- Compute strip treemap layout.
--- Returns a list of {row, col, w, h, filename, pct}.
--- @param files table
--- @param W integer window width in columns
--- @param H integer window height in rows
local function build_layout(files, W, H)
	if #files == 0 then
		return {}
	end

	local total = 0
	for _, f in ipairs(files) do
		total = total + f.statements
	end

	local rects = {}
	local cur_row = 0
	local i = 1

	while i <= #files and cur_row < H do
		local strip = {}
		local strip_total = 0
		local remaining_h = H - cur_row

		-- Greedily fill this strip, stopping when aspect ratio would worsen
		while i <= #files do
			local f = files[i]
			table.insert(strip, f)
			strip_total = strip_total + f.statements
			i = i + 1

			if i > #files then
				break
			end

			local strip_h = math.max(1, math.floor(strip_total / total * H))
			strip_h = math.min(strip_h, remaining_h)
			local avg_w = W / #strip
			local next_area = files[i].statements
			local next_total = strip_total + next_area
			local next_h = math.max(1, math.floor(next_total / total * H))
			next_h = math.min(next_h, remaining_h)
			local next_avg_w = W / (#strip + 1)

			-- Stop if next block would be narrower than 3 cols or aspect ratio worsens
			if next_avg_w < 3 then
				break
			end
			local ratio_cur = math.max(strip_h / math.max(1, avg_w), math.max(1, avg_w) / strip_h)
			local ratio_next = math.max(next_h / math.max(1, next_avg_w), math.max(1, next_avg_w) / next_h)
			if ratio_next > ratio_cur then
				break
			end
		end

		-- Final height for this strip
		local strip_h
		if i > #files then
			strip_h = remaining_h
		else
			strip_h = math.max(1, math.floor(strip_total / total * H))
			strip_h = math.min(strip_h, remaining_h)
		end

		-- Lay out files horizontally within the strip
		local cur_col = 0
		for j, f in ipairs(strip) do
			local w
			if j == #strip then
				w = W - cur_col
			else
				w = math.max(1, math.floor(f.statements / strip_total * W + 0.5))
				w = math.min(w, W - cur_col)
			end
			if w > 0 then
				table.insert(rects, {
					row = cur_row,
					col = cur_col,
					w = w,
					h = strip_h,
					filename = f.filename,
					pct = f.pct,
				})
			end
			cur_col = cur_col + w
		end

		cur_row = cur_row + strip_h
	end

	return rects
end

-- =============================================================================
-- 3. RENDERING
-- =============================================================================

--- Shorten a filename to fit within max_len characters.
local function shorten_name(filename, max_len)
	local rel = Path:new(filename):make_relative()
	if #rel <= max_len then
		return rel
	end
	return Path:new(rel):shorten(1, { 1, -1 }):sub(1, max_len)
end

--- Write text into a specific cell of the buffer (does not exceed block bounds).
local function write_text(lines, row, col, w, text)
	if w < 1 then
		return
	end
	local t = text:sub(1, w)
	-- Pad to block width so highlights stay solid
	t = t .. string.rep(" ", w - #t)
	local line = lines[row + 1]
	-- Splice t into the line at [col, col+w)
	local prefix = line:sub(1, col)
	local suffix = line:sub(col + w + 1)
	lines[row + 1] = prefix .. t .. suffix
end

--- Render the layout into bufnr.
local function render(bufnr, rects, W, H)
	-- Build blank canvas
	local lines = {}
	for _ = 1, H do
		table.insert(lines, string.rep(" ", W))
	end

	-- Write text into blocks and collect highlight calls.
	-- Each block is inset by 1 col on the right and 1 row on the bottom so the
	-- terminal background shows through as a 1-char gap between adjacent blocks.
	local highlights = {} -- {row, col, w, hl}
	for _, rect in ipairs(rects) do
		local hl = hl_for_pct(rect.pct)
		local iw = math.max(1, rect.w - 1) -- inset width  (gap on right)
		local ih = math.max(1, rect.h - 1) -- inset height (gap on bottom)

		-- Highlight the inset area only
		for r = rect.row, rect.row + ih - 1 do
			table.insert(highlights, { row = r, col = rect.col, w = iw, hl = hl })
		end

		-- Write label inside the inset area
		local pct_str = string.format("%.0f%%", rect.pct)
		local name_w = iw - 1 -- 1-char left padding
		local short = shorten_name(rect.filename, name_w)

		if ih >= 2 then
			write_text(lines, rect.row, rect.col, iw, " " .. short)
			write_text(lines, rect.row + 1, rect.col, iw, " " .. pct_str)
		elseif iw >= 6 then
			write_text(lines, rect.row, rect.col, iw, " " .. short .. " " .. pct_str)
		end
	end

	-- Flush lines into buffer
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

	-- Apply highlights
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	for _, hl in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(bufnr, ns, hl.hl, hl.row, hl.col, hl.col + hl.w)
	end
end

-- =============================================================================
-- 4. POPUP MANAGEMENT
-- =============================================================================

--- Open a full-screen floating window without a border.
local function open_float()
	local width = vim.o.columns
	local height = vim.o.lines - vim.o.cmdheight - 1

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(bufnr, "filetype", "coverage-heatmap")

	local win = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = 0,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
	})

	vim.api.nvim_win_set_option(win, "cursorline", true)
	vim.api.nvim_win_set_option(win, "wrap", false)

	return bufnr, win, width, height
end

--- Set keymaps on the heatmap buffer.
local function set_keymaps(bufnr)
	local close_cmd = ":lua require('coverage.heatmap').close()<CR>"
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", close_cmd, { silent = true, noremap = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", close_cmd, { silent = true, noremap = true })
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<CR>",
		":lua require('coverage.heatmap').open_file()<CR>",
		{ silent = true, noremap = true }
	)
end

--- Find the rect at the current cursor position.
local function rect_at_cursor()
	if popup_win == nil or layout_data == nil then
		return nil
	end
	local pos = vim.api.nvim_win_get_cursor(popup_win)
	local row = pos[1] - 1 -- 0-indexed
	local col = pos[2]
	for _, rect in ipairs(layout_data) do
		if row >= rect.row and row < rect.row + rect.h and col >= rect.col and col < rect.col + rect.w then
			return rect
		end
	end
	return nil
end

-- =============================================================================
-- 5. PUBLIC API
-- =============================================================================

--- Open the heatmap. Requires a prior coverage load.
M.show = function()
	if not cache.is_cached() then
		vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
		return
	end

	create_highlights()

	local files = build_file_list()
	if #files == 0 then
		vim.notify("No files in coverage report.", vim.log.levels.INFO)
		return
	end

	local bufnr, win, W, H = open_float()
	popup_win = win
	layout_data = build_layout(files, W, H)

	render(bufnr, layout_data, W, H)
	set_keymaps(bufnr)

	vim.api.nvim_create_autocmd("BufLeave", {
		group = augroup,
		buffer = bufnr,
		once = true,
		callback = M.close,
	})
end

--- Open the file under the cursor and close the heatmap.
M.open_file = function()
	local rect = rect_at_cursor()
	if rect == nil then
		return
	end
	local fname = rect.filename
	M.close()
	vim.cmd("edit " .. vim.fn.fnameescape(fname))
end

--- Close the heatmap window.
M.close = function()
	if popup_win ~= nil and vim.api.nvim_win_is_valid(popup_win) then
		vim.api.nvim_win_close(popup_win, true)
	end
	popup_win = nil
	layout_data = nil
end

return M
