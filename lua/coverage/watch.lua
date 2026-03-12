local M = {}

local config = require("coverage.config")

-- vim.uv is the preferred alias in Neovim 0.10+; fall back to uv for 0.9
local uv = vim.uv or uv

local fs_event = nil
local debounce_timer = nil

--- @class Event
--- @field change? boolean
--- @field rename? boolean

--- @param fname string filename to watch
--- @param change_cb fun() callback when a file changes
--- @param events? Event previous triggered events
local start

start = function(fname, change_cb, events)
	if fs_event ~= nil then
		M.stop()
	end

	if vim.fn.filereadable(fname) == 0 then
		vim.defer_fn(function()
			-- default to rename=true so change_cb fires once the file becomes readable
			start(fname, change_cb, events or { rename = true })
		end, config.opts.auto_reload.timeout_ms)
		return
	end

	if events ~= nil and events.rename then
		change_cb()
	end

	fs_event = uv.new_fs_event()
	---@diagnostic disable-next-line: unused-local
	uv.fs_event_start(
		fs_event,
		fname,
		{ watch_entry = false, stat = false, recursive = false },
		function(err, filename, ev)
			if err then
				vim.notify("Coverage watch error: " .. err, vim.log.levels.ERROR)
				M.stop()
			elseif ev.rename then
				if debounce_timer ~= nil then
					uv.timer_stop(debounce_timer)
				end
				debounce_timer = vim.defer_fn(function()
					start(fname, change_cb, ev)
				end, 0)
			else
				if debounce_timer ~= nil then
					uv.timer_stop(debounce_timer)
				end
				debounce_timer = vim.defer_fn(function()
					debounce_timer = nil
					change_cb()
				end, config.opts.auto_reload.timeout_ms)
			end
		end
	)
end

--- Starts watching a file and calls change_cb whenever it changes.
--- @param fname string
--- @param change_cb fun()
M.start = start

--- Stops the file watcher.
M.stop = function()
	if fs_event ~= nil then
		uv.fs_event_stop(fs_event)
	end
	fs_event = nil
end

return M
