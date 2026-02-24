local M = {}

local common = require("coverage.languages.common")
local config = require("coverage.config")
local Path = require("plenary.path")
local util = require("coverage.util")
local swift_json = require("coverage.parsers.swift_json")

--- Returns a list of signs to be placed.
M.sign_list = common.sign_list

--- Returns a summary report.
M.summary = common.summary

M.load = function(callback)
    local swift_config = config.opts.lang.swift
    local p = Path:new(util.get_coverage_file(swift_config.coverage_file))
    if not p:exists() then
        vim.notify("No coverage file exists.", vim.log.levels.INFO)
        return
    end
    p:read(vim.schedule_wrap(function(data)
        util.safe_decode(data, function(decoded)
            callback(swift_json.parse_table(decoded))
        end)
    end))
end

return M
