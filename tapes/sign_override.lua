-- Redefine coverage signs with a thicker block character that renders
-- correctly in VHS recordings (▌ U+258C vs the default ▎ U+258E)
vim.fn.sign_define("CoverageCovered",   { text = "▌", texthl = "CoverageCovered" })
vim.fn.sign_define("CoverageUncovered", { text = "▌", texthl = "CoverageUncovered" })
vim.fn.sign_define("CoveragePartial",   { text = "▌", texthl = "CoveragePartial" })
