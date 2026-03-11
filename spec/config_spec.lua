-- Tests for config.lua (defaults and user overrides)

local config = require("coverage.config")

describe("config.setup", function()
    before_each(function()
        config.opts = {}
    end)

    it("applies defaults when called with no args", function()
        config.setup()
        assert.is_true(config.opts.commands)
        assert.is_false(config.opts.auto_reload)
        assert.equals(500, config.opts.auto_reload_timeout_ms)
        assert.equals(80.0, config.opts.summary.min_coverage)
        assert.is_nil(config.opts.lcov_file)
    end)

    it("sets default sign texts", function()
        config.setup()
        assert.equals("▎", config.opts.signs.covered.text)
        assert.equals("▎", config.opts.signs.uncovered.text)
        assert.equals("▎", config.opts.signs.partial.text)
    end)

    it("merges user options over defaults", function()
        config.setup({ auto_reload = true, lcov_file = "coverage/lcov.info" })
        assert.is_true(config.opts.auto_reload)
        assert.equals("coverage/lcov.info", config.opts.lcov_file)
        -- defaults preserved
        assert.equals(500, config.opts.auto_reload_timeout_ms)
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
