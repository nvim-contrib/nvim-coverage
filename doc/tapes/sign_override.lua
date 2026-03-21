-- Reconfigure coverage signs with a thicker block character that renders
-- correctly in VHS recordings (▌ U+258C vs the default ▎ U+258E),
-- then reload coverage so signs appear immediately.
require("coverage").setup({
	signs = {
		covered = { hl = "CoverageCovered", text = "▌" },
		uncovered = { hl = "CoverageUncovered", text = "▌" },
		partial = { hl = "CoveragePartial", text = "▌" },
	},
})
