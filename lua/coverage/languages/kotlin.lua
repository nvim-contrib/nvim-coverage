local M = {}

local Path = require("plenary.path")
local common = require("coverage.languages.common")
local config = require("coverage.config")
local util = require("coverage.util")
local jacoco = require("coverage.parsers.jacoco")

-- Kotlin uses JaCoCo for coverage, same as Java.
-- Reuse the java config key by default; users can override with lang.kotlin.
M.config_alias = "java"

--- Returns a list of signs to be placed.
M.sign_list = common.sign_list

--- Returns a summary report.
M.summary = common.summary

--- Loads a coverage report.
-- @param callback called with results of the coverage report
M.load = function(callback)
    local kt_config = config.opts.lang.kotlin or config.opts.lang.java
    local p = Path:new(util.get_coverage_file(kt_config.coverage_file))
    if not p:exists() then
        vim.notify("No coverage file exists.", vim.log.levels.INFO)
        return
    end

    local dir_prefix = Path:new((kt_config.dir_prefix or "src/main/kotlin") .. "/").filename
    callback(jacoco.parse(p, dir_prefix))
end

return M
