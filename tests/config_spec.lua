-- Tests for config.lua (defaults and user overrides)

local config = require("coverage.config")

describe("config.setup", function()
    before_each(function()
        config.opts = {}
    end)

    it("applies defaults when called with no args", function()
        config.setup()
        assert.is_true(config.opts.commands)
        assert.is_false(config.opts.auto_reload.enabled)
        assert.equals(500, config.opts.auto_reload.timeout_ms)
        assert.equals(80.0, config.opts.report.min_coverage)
        assert.is_table(config.opts.file)
        assert.equals("lcov.info", config.opts.file[1])
    end)

    it("sets default sign texts", function()
        config.setup()
        assert.equals("▎", config.opts.signs.covered.text)
        assert.equals("▎", config.opts.signs.uncovered.text)
        assert.equals("▎", config.opts.signs.partial.text)
    end)

    it("merges user options over defaults", function()
        config.setup({ auto_reload = { enabled = true }, file = "coverage/lcov.info" })
        assert.is_true(config.opts.auto_reload.enabled)
        assert.equals("coverage/lcov.info", config.opts.file)
        -- defaults preserved
        assert.equals(500, config.opts.auto_reload.timeout_ms)
    end)

    it("deep merges highlights", function()
        config.setup({ highlights = { covered = { fg = "#FFFFFF" } } })
        assert.equals("#FFFFFF", config.opts.highlights.covered.fg)
        -- other highlights preserved
        assert.is_not_nil(config.opts.highlights.uncovered.fg)
    end)

    it("deep merges sign config", function()
        config.setup({ signs = { covered = { text = "+" } } })
        assert.equals("+", config.opts.signs.covered.text)
        -- other signs preserved
        assert.equals("▎", config.opts.signs.uncovered.text)
    end)
end)
