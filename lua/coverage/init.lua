local M = {}

local config       = require("coverage.config")
local signs        = require("coverage.signs")
local highlight    = require("coverage.highlight")
local summary      = require("coverage.report")
local report       = require("coverage.cache")
local watch        = require("coverage.watch")
local util         = require("coverage.util")
local virtual_text = require("coverage.virtual_text")
local overlay      = require("coverage.overlay")
local quickfix     = require("coverage.quickfix")
local loclist      = require("coverage.loclist")

--- Opens vim.ui.select with all *.info files found under cwd, then loads the chosen file.
--- @param place? boolean true to immediately place signs
local pick_and_load = function(place)
    local cwd = vim.fn.getcwd()
    local candidates = vim.fn.globpath(cwd, "**/*.info", false, true)
    if #candidates == 0 then
        vim.notify("No *.info files found under " .. cwd, vim.log.levels.INFO)
        return
    end
    if #candidates == 1 then
        M.load(candidates[1], place)
        return
    end
    -- Make paths relative for readability in the picker
    local rel = {}
    for _, p in ipairs(candidates) do
        table.insert(rel, p:sub(#cwd + 2))
    end
    vim.ui.select(rel, { prompt = "Select coverage file:" }, function(choice)
        if choice then
            M.load(cwd .. "/" .. choice, place)
        end
    end)
end

--- Setup the coverage plugin.
--- @param user_opts? Configuration
M.setup = function(user_opts)
    config.setup(user_opts)
    signs.setup()
    highlight.setup()

    if config.opts.commands then
        vim.cmd([[
    command! CoverageShow lua require('coverage').show()
    command! CoverageHide lua require('coverage').hide()
    command! CoverageToggle lua require('coverage').toggle()
    command! CoverageClear lua require('coverage').clear()
    command! CoverageReport lua require('coverage').report()
    command! CoverageToggleLineHits lua require('coverage').toggle_line_hits()
    command! CoverageToggleBranchHits lua require('coverage').toggle_branch_hits()
    ]])
        if vim.fn.executable("genhtml") == 1 then
            vim.cmd([[command! CoverageBrowser lua require('coverage').browser()]])
        end
        vim.api.nvim_create_user_command("CoverageLoad", function(opts)
            if opts.bang then
                pick_and_load(nil)
            else
                local file = opts.args ~= "" and opts.args or nil
                require("coverage").load(file)
            end
        end, { nargs = "?", bang = true })
        vim.api.nvim_create_user_command("CoverageQuickfix", function(opts)
            require("coverage").quickfix(opts.args ~= "" and opts.args or nil)
        end, { nargs = "?" })
        vim.api.nvim_create_user_command("CoverageLoclist", function(opts)
            require("coverage").loclist(opts.args ~= "" and opts.args or nil)
        end, { nargs = "?" })
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
        report.set(data, file)
        local sign_list = signs.build(data)
        if place or signs.is_enabled() then
            signs.place(sign_list)
        else
            signs.cache(sign_list)
        end
        if config.opts.line_hits.enabled or virtual_text.is_enabled() then
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

--- Hides signs, clears cache, stops file watcher, disables virtual text and branch overlay.
M.clear = function()
    signs.clear()
    virtual_text.clear()
    overlay.disable()
    report.clear()
    watch.stop()
end

--- Displays a pop-up with a coverage report.
M.report = summary.show

--- Toggles branch overlay popup. Shows per-branch execution counts when cursor is on a partial line.
M.toggle_branch_hits = function()
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
M.toggle_line_hits = function()
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

--- Populates the quickfix list with one entry per file.
--- @param filter? "uncovered" Only include files with uncovered lines.
M.quickfix = quickfix.populate

--- Populates the location list with lines of the given type in the current buffer.
--- @param sign_type? "uncovered"|"partial" Defaults to "uncovered".
M.loclist = loclist.populate

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

--- Generates an HTML coverage report from the loaded lcov file and opens it in the browser.
--- Requires genhtml to be installed. No-op if no report is loaded.
M.browser = function()
    local lcov_file = report.get_file()
    if lcov_file == nil then
        vim.notify("Coverage report not loaded.", vim.log.levels.INFO)
        return
    end

    local tmpdir = vim.fn.tempname()
    vim.fn.mkdir(tmpdir, "p")

    vim.fn.jobstart({ "genhtml", lcov_file, "-o", tmpdir }, {
        on_exit = function(_, code)
            if code ~= 0 then
                vim.notify("genhtml failed (exit code " .. code .. ")", vim.log.levels.ERROR)
                return
            end
            local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
            vim.fn.jobstart({ opener, tmpdir .. "/index.html" })
        end,
    })
end

return M
