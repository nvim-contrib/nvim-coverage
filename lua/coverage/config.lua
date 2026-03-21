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
--- @field highlight Highlight

--- @class Configuration
--- @field auto_reload AutoReloadOpts automatically reload when lcov file changes
--- @field commands boolean register vim commands on setup
--- @field highlights HighlightConfig
--- @field on_load fun() callback after coverage is loaded
--- @field signs SignsConfig
--- @field report ReportOpts
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
	highlights = {
		covered = { fg = "#B7F071" },
		uncovered = { fg = "#F07178" },
		partial = { fg = "#AA71F0" },
	},
	on_load = nil,

	--- @class SignsConfig
	--- @field covered Sign
	--- @field uncovered Sign
	--- @field partial Sign
	--- @field group string name of the sign group (:h sign-group)
	signs = {
		covered   = { hl = "CoverageCovered",   text = "▎" },
		uncovered = { hl = "CoverageUncovered", text = "▎" },
		partial   = { hl = "CoveragePartial",   text = "▎" },
		group   = "coverage",
		signhl  = true,  -- show glyph in sign column
		numhl   = false, -- color the line number (opt-in)
		linehl  = false, -- color the entire line background (opt-in)
	},

	--- @class ReportHighlightConfig
	--- @field border Highlight
	--- @field normal Highlight
	--- @field cursor_line Highlight
	--- @field header Highlight
	--- @field pass Highlight
	--- @field fail Highlight

	--- @class ReportOpts
	--- @field width number
	--- @field height number
	--- @field min_coverage number
	--- @field highlights ReportHighlightConfig
	report = {
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
			highlight = "Normal:CoverageReportBorder",
		},
		window = {},
		min_coverage = 80.0,
		highlights = {
			border = { link = "FloatBorder" },
			normal = { link = "NormalFloat" },
			cursor_line = { link = "CursorLine" },
			header = { style = "bold,underline", sp = "fg" },
			pass = { link = "CoverageCovered" },
			fail = { link = "CoverageUncovered" },
		},
	},

	line_hits = {
		enabled = false,
		position = "eol",
		highlight = { link = "Comment" },
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
