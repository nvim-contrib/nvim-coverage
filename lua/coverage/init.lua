local M = {}

local config = require("coverage.config")
local signs = require("coverage.signs")
local highlight = require("coverage.highlight")
local summary = require("coverage.summary")
local report = require("coverage.report")
local watch = require("coverage.watch")
local lcov = require("coverage.lcov")
local util = require("coverage.util")

--- Custom language registry: populated via M.register_language().
--- Keys are filetype strings; values are language modules.
local custom_languages = {}

--- Setup the coverage plugin.
-- Also defines signs, creates highlight groups.
-- @param config options
M.setup = function(user_opts)
    config.setup(user_opts)
    signs.setup()
    highlight.setup()

    -- add commands
    if config.opts.commands then
        vim.cmd([[
    command! Coverage lua require('coverage').load(true)
    command! CoverageLoad lua require('coverage').load()
    command! -nargs=? CoverageLoadLcov lua require('coverage').load_lcov(<f-args>)
    command! CoverageShow lua require('coverage').show()
    command! CoverageHide lua require('coverage').hide()
    command! CoverageToggle lua require('coverage').toggle()
    command! CoverageClear lua require('coverage').clear()
    command! CoverageSummary lua require('coverage').summary()
    command! CoverageQuickfix lua require('coverage.qflist').set_qflist()
    command! CoverageLoclist lua require('coverage.qflist').set_loclist()
    command! CoverageVirtual lua require('coverage').virtual_text_toggle()
    ]])
    end
end

--- Registers a custom language module under the given filetype name.
--- The module must implement load(callback), sign_list(data), summary(data).
--- Custom modules take precedence over built-in language modules.
--- @param name string filetype name (e.g. "myfiletype")
--- @param module table language module with load/sign_list/summary functions
M.register_language = function(name, module)
    assert(type(name) == "string", "register_language: name must be a string")
    assert(type(module) == "table", "register_language: module must be a table")
    assert(type(module.load) == "function", "register_language: module.load must be a function")
    custom_languages[name] = module
end

--- Loads a coverage report but does not place signs.
--- @param place boolean true to immediately place signs
M.load = function(place)
    local ftype = vim.bo.filetype

    -- Check custom registry first, then fall back to built-in language modules.
    local lang = custom_languages[ftype]
    if lang == nil then
        local ok, builtin = pcall(require, "coverage.languages." .. ftype)
        if not ok then
            vim.notify("Coverage report not available for filetype " .. ftype)
            return
        end
        lang = builtin
    end

    local vt = require("coverage.virtual_text")

    local load_lang = function()
        lang.load(function(result)
            if config.opts.load_coverage_cb ~= nil then
                vim.schedule(function()
                    config.opts.load_coverage_cb(ftype)
                end)
            end
            report.cache(result, ftype)
            local sign_list = lang.sign_list(result)
            if place or signs.is_enabled() then
                signs.place(sign_list)
            else
                signs.cache(sign_list)
            end
            -- Show virtual text if configured to auto-enable, or refresh if already shown
            if config.opts.virtual_text.enabled or vt.is_enabled() then
                vt.show(result)
            end
        end)
    end

    local lang_config = config.opts.lang[ftype]
    if lang_config == nil then
        lang_config = config.opts.lang[lang.config_alias]
    end

    -- Automatically watch the coverage file for updates when auto_reload is enabled
    -- and when the language setup allows it
    if config.opts.auto_reload and
        lang_config ~= nil and
        lang_config.coverage_file ~= nil and
        not lang_config.disable_auto_reload then
        local coverage_file = util.get_coverage_file(lang_config.coverage_file)
        watch.start(coverage_file, load_lang)
    end

    signs.clear()
    load_lang()
end

-- Load an lcov file
M.load_lcov = lcov.load_lcov

-- Shows signs, if loaded.
M.show = signs.show

-- Hides signs.
M.hide = signs.unplace

--- Toggles signs.
M.toggle = signs.toggle

--- Hides and clears cached signs.
M.clear = function()
    signs.clear()
    require("coverage.virtual_text").hide()
    watch.stop()
end

--- Displays a pop-up with a coverage summary report.
M.summary = summary.show

--- Toggle virtual text annotations.
M.virtual_text_toggle = function()
    if not report.is_cached() then
        vim.notify("Coverage report not loaded.", vim.log.levels.WARN)
        return
    end
    require("coverage.virtual_text").toggle(report.get())
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

--- Returns coverage statistics for the given buffer (defaults to current buffer).
--- Returns nil if no coverage data is loaded for the buffer.
--- @param bufname? string absolute path or buffer name; defaults to current buffer
--- @return {covered: integer, total: integer, percent: number, is_covered: boolean}|nil
M.get_stats = function(bufname)
    if not report.is_cached() then
        return nil
    end
    local fname = bufname or vim.api.nvim_buf_get_name(0)
    local data = report.get()
    local cov = data.files[fname]
    if cov == nil then
        -- Try relative path lookup
        local Path = require("plenary.path")
        local rel = Path:new(fname):make_relative()
        cov = data.files[rel]
    end
    if cov == nil then
        return nil
    end
    return {
        covered = cov.summary.covered_lines,
        total = cov.summary.num_statements,
        percent = cov.summary.percent_covered,
        is_covered = cov.summary.percent_covered >= (config.opts.summary.min_coverage or 80),
    }
end

--- Returns a formatted coverage string for the current buffer, suitable for
--- use in a statusline or winbar (e.g. via lualine's 'eval' component).
--- Returns an empty string if no data is available.
--- @return string  e.g. "87%" or ""
M.file_coverage_str = function()
    local stats = M.get_stats()
    if stats == nil or stats.total == 0 then
        return ""
    end
    return string.format("%.0f%%", stats.percent)
end

return M
