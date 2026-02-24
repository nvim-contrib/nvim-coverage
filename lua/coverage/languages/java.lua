local M = {}

local Path = require "plenary.path"
local common = require "coverage.languages.common"
local config = require "coverage.config"
local util = require "coverage.util"
local jacoco = require "coverage.parsers.jacoco"

--- Returns a list of signs to be placed.
M.sign_list = common.sign_list

--- Returns a summary report.
M.summary = common.summary

--- Loads a coverage report.
-- @param callback called with results of the coverage report
M.load = function(callback)
    -- Try and load file
    local opt = config.opts.lang.java.coverage_file
    local p = Path:new(util.get_coverage_file(opt))
    if not p:exists() then
        vim.notify("No coverage file exists.", vim.log.levels.INFO)
        return
    end

    local dir_prefix = Path:new(config.opts.lang.java.dir_prefix .. "/").filename

    callback(jacoco.parse(p, dir_prefix))
end

return M
