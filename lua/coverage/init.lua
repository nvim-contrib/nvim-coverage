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
		local action_complete = function()
			return { "show", "hide", "toggle" }
		end

		local function action_cmd(actions)
			return function(opts)
				local action = opts.args ~= "" and opts.args or "toggle"
				local fn = actions[action]
				if fn then
					fn()
				else
					vim.notify("Invalid action: " .. action, vim.log.levels.ERROR)
				end
			end
		end

		vim.api.nvim_create_user_command("CoverageSigns", action_cmd({
			show = require("coverage").show_line_signs,
			hide = require("coverage").hide_line_signs,
			toggle = require("coverage").toggle_line_signs,
		}), { nargs = "?", complete = action_complete })

		vim.api.nvim_create_user_command("CoverageHints", action_cmd({
			show = require("coverage").show_line_hints,
			hide = require("coverage").hide_line_hints,
			toggle = require("coverage").toggle_line_hints,
		}), { nargs = "?", complete = action_complete })

		vim.api.nvim_create_user_command("CoverageBranches", action_cmd({
			show = require("coverage").show_branch_hints,
			hide = require("coverage").hide_branch_hints,
			toggle = require("coverage").toggle_branch_hints,
		}), { nargs = "?", complete = action_complete })

		vim.api.nvim_create_user_command("CoverageClear", function()
			require("coverage").clear()
		end, {})
		vim.api.nvim_create_user_command("CoverageReport", function()
			require("coverage").report()
		end, {})
		vim.api.nvim_create_user_command("CoverageHeatmap", function()
			require("coverage").heatmap()
		end, {})
		vim.api.nvim_create_user_command("CoverageBrowser", function()
			require("coverage").browser()
		end, {})
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
		local data = util.lcov_to_table(p)
		cache.set(data, file)
		if config.opts.on_load ~= nil then
			vim.schedule(config.opts.on_load)
		end
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
