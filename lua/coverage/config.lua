local M = {
    --- @type Configuration
    opts = {},
}

--- @class Configuration
--- @field auto_reload boolean automatically reload when lcov file changes
--- @field auto_reload_timeout_ms integer debounce timeout for auto reload
--- @field commands boolean register vim commands on setup
--- @field highlights HighlightConfig
--- @field load_coverage_cb fun(ftype: string) callback after coverage is loaded
--- @field signs SignsConfig
--- @field sign_group string name of the sign group (:h sign_placelist)
--- @field summary SummaryOpts
--- @field file string|string[]|nil path or list of paths to the lcov file (first existing wins)
local defaults = {
    auto_reload = false,
    auto_reload_timeout_ms = 500,
    commands = true,

    --- @class HighlightConfig
    --- @field covered Highlight
    --- @field uncovered Highlight
    --- @field partial Highlight
    --- @field summary_border Highlight
    --- @field summary_normal Highlight
    --- @field summary_cursor_line Highlight
    --- @field summary_header Highlight
    --- @field summary_pass Highlight
    --- @field summary_fail Highlight
    highlights = {
        covered = { fg = "#B7F071" },
        uncovered = { fg = "#F07178" },
        partial = { fg = "#AA71F0" },
        summary_border = { link = "FloatBorder" },
        summary_normal = { link = "NormalFloat" },
        summary_cursor_line = { link = "CursorLine" },
        summary_header = { style = "bold,underline", sp = "fg" },
        summary_pass = { link = "CoverageCovered" },
        summary_fail = { link = "CoverageUncovered" },
    },
    load_coverage_cb = nil,

    --- @class SignsConfig
    --- @field covered Sign
    --- @field uncovered Sign
    --- @field partial Sign
    signs = {
        covered = { hl = "CoverageCovered", text = "▎" },
        uncovered = { hl = "CoverageUncovered", text = "▎" },
        partial = { hl = "CoveragePartial", text = "▎" },
    },
    sign_group = "coverage",

    --- @class SummaryOpts
    --- @field width_percentage number
    --- @field height_percentage number
    --- @field min_coverage number
    summary = {
        width_percentage = 0.70,
        height_percentage = 0.50,
        borders = {
            topleft = "╭",
            topright = "╮",
            top = "─",
            left = "│",
            right = "│",
            botleft = "╰",
            botright = "╯",
            bot = "─",
            highlight = "Normal:CoverageSummaryBorder",
        },
        window = {},
        min_coverage = 80.0,
    },

    file = nil,
}

--- Setup configuration values.
M.setup = function(config)
    M.opts = vim.tbl_deep_extend("force", M.opts, defaults)
    if config ~= nil then
        M.opts = vim.tbl_deep_extend("force", M.opts, config)
    end
end

return M
