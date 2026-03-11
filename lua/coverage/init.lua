local M = {}

local config       = require("coverage.config")
local signs        = require("coverage.signs")
local highlight    = require("coverage.highlight")
local summary      = require("coverage.summary")
local report       = require("coverage.report")
local watch        = require("coverage.watch")
local util         = require("coverage.util")
local virtual_text = require("coverage.virtual_text")
local overlay      = require("coverage.overlay")

--- Setup the coverage plugin.
--- @param user_opts? Configuration
M.setup = function(user_opts)
    config.setup(user_opts)
    signs.setup()
    highlight.setup()

    if config.opts.commands then
        vim.cmd([[
    command! -nargs=? CoverageLoad lua require('coverage').load(<f-args>)
    command! CoverageShow lua require('coverage').show()
    command! CoverageHide lua require('coverage').hide()
    command! CoverageToggle lua require('coverage').toggle()
    command! CoverageClear lua require('coverage').clear()
    command! CoverageSummary lua require('coverage').summary()
    command! CoverageToggleHitCounts lua require('coverage').toggle_hit_counts()
    command! CoverageToggleBranchOverlay lua require('coverage').toggle_branch_overlay()
    ]])
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
--- @param place? boolean true to immediately place signs
M.load = function(file, place)
    file = resolve_file(file) or resolve_file(config.opts.file)
    if file == nil then
        vim.notify("A path to the lcov file was not supplied.", vim.log.levels.INFO)
        return
    end

    local p = require("plenary.path"):new(file)
    if not p:exists() then
        vim.notify("No coverage file exists at: " .. file, vim.log.levels.INFO)
        return
    end

    local reload = function()
        if config.opts.on_load ~= nil then
            vim.schedule(config.opts.on_load)
        end
        local data = util.lcov_to_table(p)
        report.set(data)
        local sign_list = signs.build(data)
        if place or signs.is_enabled() then
            signs.place(sign_list)
        else
            signs.cache(sign_list)
        end
        if config.opts.virtual_text.enabled or virtual_text.is_enabled() then
            virtual_text.place(data)
        end
    end

    watch.start(file, reload)
    reload()
end

--- Shows signs, if loaded.
M.show = signs.show

--- Hides signs.
M.hide = signs.unplace

--- Toggles signs.
M.toggle = signs.toggle

--- Hides signs, clears cache, stops file watcher.
M.clear = function()
    signs.clear()
    virtual_text.clear()
    overlay.disable()
    report.clear()
    watch.stop()
end

--- Displays a pop-up with a coverage summary report.
M.summary = summary.show

--- Toggles branch overlay popup for partial lines.
M.toggle_branch_overlay = function()
    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
        return
    end
    if overlay.is_enabled() then
        overlay.disable()
    else
        overlay.enable()
    end
end

--- Toggles virtual text hit counts.
M.toggle_hit_counts = function()
    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
        return
    end
    if virtual_text.is_enabled() then
        virtual_text.clear()
    else
        virtual_text.place(report.get())
    end
end

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

return M
