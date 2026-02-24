local M = {}

local config = require("coverage.config")

local fs_event = nil
local debounce_timer = nil
--- Timestamp (ms) of the last self-triggered write.  When a coverage command
--- generates the coverage file itself (e.g. Julia), we record the time here so
--- that the resulting fs_event is silently ignored for a short cooldown period.
local self_write_ts = nil
local self_write_cooldown_ms = 2000

--- @class Event
--- @field change? boolean
--- @field rename? boolean

--- @param fname string filename to watch
--- @param change_cb fun() callback when a file changes
--- @param events? Event previous triggered events
local function watch(fname, change_cb, events)
    if fs_event ~= nil then
        M.stop()
    end

    if vim.fn.filereadable(fname) == 0 then
        vim.defer_fn(function()
            -- if events is nil, default to rename = true to trigger change_cb when the file is readable
            -- this can happen if the file does not initially exist when coverage.load() is called but is created later
            local ev = events or { rename = true }
            watch(fname, change_cb, ev)
        end, config.opts.auto_reload_timeout_ms)
        return
    end

    if events ~= nil and events.rename then
        -- the file was deleted and recreated
        -- Skip if the recreation was triggered by ourselves (e.g. Julia command)
        if self_write_ts == nil or (vim.loop.now() - self_write_ts) > self_write_cooldown_ms then
            change_cb()
        end
        self_write_ts = nil
    end

    fs_event = vim.loop.new_fs_event()
    local flags = {
        watch_entry = false,
        stat = false,
        recursive = false,
    }
    ---@diagnostic disable-next-line: unused-local
    local cb = function(err, filename, ev)
        if err then
            vim.notify("Coverage watch error: " .. err, vim.log.levels.ERROR)
            M.stop()
        elseif ev.rename then
            if debounce_timer ~= nil then
                vim.loop.timer_stop(debounce_timer)
            end
            -- reschedule immediately to watch for the file to be recreated
            debounce_timer = vim.defer_fn(function()
                watch(fname, change_cb, ev)
            end, 0)
        else
            -- Ignore change events that immediately follow a self-triggered write
            if self_write_ts ~= nil and (vim.loop.now() - self_write_ts) <= self_write_cooldown_ms then
                return
            end
            if debounce_timer ~= nil then
                vim.loop.timer_stop(debounce_timer)
            end
            debounce_timer = vim.defer_fn(function()
                debounce_timer = nil
                change_cb()
            end, config.opts.auto_reload_timeout_ms)
        end
    end
    vim.loop.fs_event_start(fs_event, fname, flags, cb)
end

--- Starts the file watcher that executes a callback when a file changes.
--- @param fname string filename to watch
--- @param change_cb fun() callback when a file changes
M.start = function(fname, change_cb)
    watch(fname, change_cb)
end

--- Stops the file watcher.
M.stop = function()
    if fs_event ~= nil then
        vim.loop.fs_event_stop(fs_event)
    end
    fs_event = nil
end

--- Record that the coverage file is about to be written by the plugin itself.
--- Call this immediately before running a coverage command that writes the
--- watched file (e.g. Julia's coverage_command) so the resulting fs_event is
--- ignored for a short cooldown window.
M.mark_self_write = function()
    self_write_ts = vim.loop.now()
end

return M
