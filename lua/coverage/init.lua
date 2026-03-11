local M = {}

local config = require("coverage.config")
local signs = require("coverage.signs")
local highlight = require("coverage.highlight")
local summary = require("coverage.summary")
local report = require("coverage.report")
local watch = require("coverage.watch")
local lcov = require("coverage.lcov")

--- Setup the coverage plugin.
-- Also defines signs, creates highlight groups.
-- @param config options
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
    ]])
    end
end

--- Loads an lcov file and optionally places signs immediately.
--- @param file? string path to the lcov file (defaults to config.opts.lcov_file)
--- @param place? boolean true to immediately place signs
M.load = lcov.load

-- Shows signs, if loaded.
M.show = signs.show

-- Hides signs.
M.hide = signs.unplace

--- Toggles signs.
M.toggle = signs.toggle

--- Hides and clears cached signs.
M.clear = function()
    signs.clear()
    report.clear()
    watch.stop()
end

--- Displays a pop-up with a coverage summary report.
M.summary = summary.show

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
