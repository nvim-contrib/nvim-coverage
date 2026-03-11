local M = {}

local Path = require("plenary.path")
local config = require("coverage.config")
local report = require("coverage.report")
local signs = require("coverage.signs")
local util = require("coverage.util")
local watch = require("coverage.watch")

--- Loads a coverage report from an lcov file.
--- @param file? string path to the lcov file (defaults to config.opts.lcov_file)
--- @param place? boolean true to immediately place signs
M.load = function(file, place)
    if file == nil then
        file = config.opts.lcov_file
    end
    if file == nil then
        vim.notify("A path to the lcov file was not supplied.", vim.log.levels.INFO)
        return
    end
    local p = Path:new(file)
    if not p:exists() then
        vim.notify("No coverage file exists at: " .. file, vim.log.levels.INFO)
        return
    end

    local load_lcov = function()
        if config.opts.load_coverage_cb ~= nil then
            vim.schedule(function()
                config.opts.load_coverage_cb("lcov")
            end)
        end

        local result = util.lcov_to_table(p)
        report.cache(result, "lcov")
        local sign_list = signs.build(result)
        if place or signs.is_enabled() then
            signs.place(sign_list)
        else
            signs.cache(sign_list)
        end
    end

    watch.start(file, load_lcov)
    load_lcov()
end

return M
