local M = {}

local Path = require("plenary.path")
local common = require("coverage.languages.common")
local config = require("coverage.config")
local util = require("coverage.util")
local ruby_json = require("coverage.parsers.ruby_json")

--- Returns a list of signs to be placed.
M.sign_list = common.sign_list

--- Returns a summary report.
M.summary = common.summary

--- Loads a coverage report.
-- @param callback called with the list of signs from the coverage report
M.load = function(callback)
    local ruby_config = config.opts.lang.ruby
    local p = Path:new(util.get_coverage_file(ruby_config.coverage_file))
    if not p:exists() then
        vim.notify("No coverage file exists.", vim.log.levels.INFO)
        return
    end
    callback(ruby_json.parse(p))
end

return M
