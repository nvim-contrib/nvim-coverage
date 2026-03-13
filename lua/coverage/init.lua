local M = {}

local config = require("coverage.config")
local signs = require("coverage.signs")
local highlight = require("coverage.highlight")
local report = require("coverage.report")
local cache = require("coverage.cache")
local watch = require("coverage.watch")
local util = require("coverage.util")
local hints = require("coverage.hints")
local overlay = require("coverage.overlay")
local quickfix = require("coverage.quickfix")
local loclist = require("coverage.loclist")

--- Opens vim.ui.select with all *.info files found under cwd, then loads the chosen file.
--- @param place? boolean true to immediately place signs
local pick_and_load = function(place)
	local cwd = vim.fn.getcwd()
	local candidates = vim.fn.globpath(cwd, "**/*.info", false, true)
	if #candidates == 0 then
		vim.notify("No *.info files found under " .. cwd, vim.log.levels.INFO)
		return
	end
	if #candidates == 1 then
		M.load(candidates[1], place)
		return
	end
	-- Make paths relative for readability in the picker
	local rel = {}
	for _, p in ipairs(candidates) do
		table.insert(rel, p:sub(#cwd + 2))
	end
	vim.ui.select(rel, { prompt = "Select coverage file:" }, function(choice)
		if choice then
			M.load(cwd .. "/" .. choice, place)
		end
	end)
end

--- Setup the coverage plugin.
--- @param user_opts? Configuration
M.setup = function(user_opts)
	config.setup(user_opts)
	signs.setup()
	highlight.setup()

	if config.opts.commands then
		vim.cmd([[
    command! CoverageShowLineSigns lua require('coverage').show_line_signs()
    command! CoverageHideLineSigns lua require('coverage').hide_line_signs()
    command! CoverageToggleLineSigns lua require('coverage').toggle_line_signs()
    command! CoverageClear lua require('coverage').clear()
    command! CoverageReport lua require('coverage').report()
    command! CoverageHeatmap lua require('coverage').heatmap()
    command! CoverageShowLineHints lua require('coverage').show_line_hints()
    command! CoverageHideLineHints lua require('coverage').hide_line_hints()
    command! CoverageToggleLineHints lua require('coverage').toggle_line_hints()
    command! CoverageShowBranchHints lua require('coverage').show_branch_hints()
    command! CoverageHideBranchHints lua require('coverage').hide_branch_hints()
    command! CoverageToggleBranchHints lua require('coverage').toggle_branch_hints()
    ]])
		if vim.fn.executable("genhtml") == 1 then
			vim.cmd([[command! CoverageBrowser lua require('coverage').browser()]])
		end
		vim.api.nvim_create_user_command("CoverageLoad", function(opts)
			if opts.bang then
				pick_and_load(nil)
			else
				local file = opts.args ~= "" and opts.args or nil
				require("coverage").load(file)
			end
		end, { nargs = "?", bang = true })
		vim.api.nvim_create_user_command("CoverageQuickfix", function(opts)
			require("coverage").quickfix(opts.args ~= "" and opts.args or nil)
		end, { nargs = "?" })
		vim.api.nvim_create_user_command("CoverageLoclist", function(opts)
			require("coverage").loclist(opts.args ~= "" and opts.args or nil)
		end, { nargs = "?" })
	end
end

--- Resolves file config to a single existing path, or nil.
--- Accepts a string or a list of strings (first existing path wins).
--- @param file? string|string[]
--- @return string|nil
local resolve_file = function(file)
	if type(file) == "string" then
		return file
	elseif type(file) == "table" then
		local Path = require("plenary.path")
		for _, candidate in ipairs(file) do
			if Path:new(candidate):exists() then
				return candidate
			end
		end
	end
	return nil
end

--- Loads an lcov file and optionally places signs immediately.
--- @param file? string|string[] path(s) to the lcov file (defaults to config.opts.file)
--- @param opts? boolean|{place?: boolean, silent?: boolean} options or legacy boolean (place)
M.load = function(file, opts)
	local place, silent
	if type(opts) == "boolean" then
		place = opts
	elseif type(opts) == "table" then
		place = opts.place
		silent = opts.silent
	end

	file = resolve_file(file) or resolve_file(config.opts.file)
	if file == nil then
		if not silent then
			vim.notify("A path to the lcov file was not supplied.", vim.log.levels.INFO)
		end
		return
	end

	local p = require("plenary.path"):new(file)
	if not p:exists() then
		if not silent then
			vim.notify("No coverage file exists at: " .. file, vim.log.levels.INFO)
		end
		return
	end

	local reload = function()
		if config.opts.on_load ~= nil then
			vim.schedule(config.opts.on_load)
		end
		local data = util.lcov_to_table(p)
		cache.set(data, file)
		local sign_list = signs.build(data)
		if place or signs.is_enabled() then
			signs.place(sign_list)
		else
			signs.cache(sign_list)
		end
		if config.opts.line_hits.enabled or hints.is_enabled() then
			hints.place(data)
		end
	end

	watch.start(file, reload)
	reload()
end

--- Shows line signs, if loaded.
M.show_line_signs = signs.show

--- Hides line signs.
M.hide_line_signs = signs.unplace

--- Toggles line signs.
M.toggle_line_signs = signs.toggle

--- Hides signs, clears cache, stops file watcher, disables line hints and branch hints.
M.clear = function()
	signs.clear()
	hints.clear()
	overlay.disable()
	cache.clear()
	watch.stop()
end

--- Displays a pop-up with a coverage report.
M.report = report.show

--- Opens the heatmap treemap in a full-screen floating window.
M.heatmap = function()
	require("coverage.heatmap").show()
end

--- Shows line hints (virtual text hit counts).
M.show_line_hints = function()
	if not cache.is_cached() then
		vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
		return
	end
	hints.place(cache.get())
end

--- Hides line hints.
M.hide_line_hints = function()
	hints.clear()
end

--- Toggles line hints.
M.toggle_line_hints = function()
	if not cache.is_cached() then
		vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
		return
	end
	if hints.is_enabled() then
		M.hide_line_hints()
	else
		M.show_line_hints()
	end
end

--- Shows branch hints popup. Shows per-branch execution counts when cursor is on a partial line.
M.show_branch_hints = function()
	if not cache.is_cached() then
		vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
		return
	end
	overlay.enable()
end

--- Hides branch hints popup.
M.hide_branch_hints = function()
	overlay.disable()
end

--- Toggles branch hints popup.
M.toggle_branch_hints = function()
	if not cache.is_cached() then
		vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
		return
	end
	if overlay.is_enabled() then
		M.hide_branch_hints()
	else
		M.show_branch_hints()
	end
end

--- Populates the quickfix list with one entry per file.
--- @param filter? "uncovered" Only include files with uncovered lines.
M.quickfix = quickfix.populate

--- Populates the location list with lines of the given type in the current buffer.
--- @param sign_type? "uncovered"|"partial" Defaults to "uncovered".
M.loclist = loclist.populate

--- Jumps to the next sign of the given type.
--- @param sign_type? "covered"|"uncovered"|"partial" Defaults to "covered"
M.jump_next = function(sign_type)
	signs.jump(sign_type, 1)
end

--- Jumps to the previous sign of the given type.
--- @param sign_type? "covered"|"uncovered"|"partial" Defaults to "covered"
M.jump_prev = function(sign_type)
	signs.jump(sign_type, -1)
end

--- Generates an HTML coverage report from the loaded lcov file and opens it in the browser.
--- Requires genhtml to be installed. No-op if no report is loaded.
M.browser = function()
	local lcov_file = cache.get_file()
	if lcov_file == nil then
		vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
		return
	end

	local tmpdir = vim.fn.tempname()
	vim.fn.mkdir(tmpdir, "p")

	vim.fn.jobstart({ "genhtml", lcov_file, "-o", tmpdir }, {
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("genhtml failed (exit code " .. code .. ")", vim.log.levels.ERROR)
				return
			end
			local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
			vim.fn.jobstart({ opener, tmpdir .. "/index.html" })
		end,
	})
end

return M
