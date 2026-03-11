local M = {
    --- @type Configuration
    opts = {},
}

--- @class AutoReloadOpts
--- @field enabled boolean
--- @field timeout_ms integer

--- @class LineHitsOpts
--- @field enabled boolean show hit counts as virtual text
--- @field position "eol"|"right_align"|"inline" virtual text position

--- @class Configuration
--- @field auto_reload AutoReloadOpts automatically reload when lcov file changes
--- @field commands boolean register vim commands on setup
--- @field highlights HighlightConfig
--- @field on_load fun() callback after coverage is loaded
--- @field signs SignsConfig
--- @field sign_group string name of the sign group (:h sign_placelist)
--- @field summary SummaryOpts
--- @field line_hits LineHitsOpts
--- @field file string|string[]|nil path or list of paths to the lcov file (first existing wins)
local defaults = {
    auto_reload = {
        enabled = false,
        timeout_ms = 500,
    },
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
    --- @field line_hits Highlight
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
        line_hits = { link = "Comment" },
    },
    on_load = nil,

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
    --- @field width number
    --- @field height number
    --- @field min_coverage number
    summary = {
        width = 0.70,
        height = 0.50,
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

    line_hits = {
        enabled = false,
        position = "eol",
    },

    file = {
        "lcov.info",
        "cover/lcov.info",
        "coverage/lcov.info",
        "target/lcov.info",
    },
}

--- Setup configuration values.
M.setup = function(config)
    M.opts = vim.tbl_deep_extend("force", M.opts, defaults)
    if config ~= nil then
        M.opts = vim.tbl_deep_extend("force", M.opts, config)
    end
end

return M
