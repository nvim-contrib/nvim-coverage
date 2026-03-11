-- Tests for overlay.lua (branch overlay state management)

local overlay = require("coverage.overlay")
local report  = require("coverage.report")

local make_data = function(branches)
    return {
        files = {
            ["/project/src/foo.lua"] = {
                covered_lines   = { 1, 2 },
                uncovered_lines = {},
                partial_lines   = {},
                hit_counts      = {},
                branches        = branches or {},
            },
        },
        totals = {},
    }
end

describe("overlay", function()
    before_each(function()
        overlay.disable()
        report.clear()
    end)

    after_each(function()
        overlay.disable()
        report.clear()
    end)

    it("is disabled by default", function()
        assert.is_false(overlay.is_enabled())
    end)

    it("enable sets is_enabled to true", function()
        report.set(make_data())
        overlay.enable()
        assert.is_true(overlay.is_enabled())
    end)

    it("disable sets is_enabled to false", function()
        report.set(make_data())
        overlay.enable()
        overlay.disable()
        assert.is_false(overlay.is_enabled())
    end)

    it("enable is idempotent", function()
        report.set(make_data())
        overlay.enable()
        overlay.enable()
        assert.is_true(overlay.is_enabled())
    end)
end)

describe("util.lcov_to_table branches field", function()
    local Path = require("plenary.path")
    local util = require("coverage.util")

    local fixture = function(name)
        return Path:new(vim.fn.getcwd() .. "/spec/fixtures/" .. name)
    end

    it("stores all BRDA lines per line number", function()
        local data = util.lcov_to_table(fixture("branches.lcov"))
        local baz = data.files["/project/src/baz.lua"]
        -- BRDA:2,0,0,1 and BRDA:2,0,1,0
        assert.equals(2, #baz.branches[2])
    end)

    it("stores block and branch number", function()
        local data = util.lcov_to_table(fixture("branches.lcov"))
        local b = data.files["/project/src/baz.lua"].branches[2][1]
        assert.equals(0, b.block)
        assert.equals(0, b.branch)
    end)

    it("stores taken count for hit branches", function()
        local data = util.lcov_to_table(fixture("branches.lcov"))
        -- BRDA:2,0,0,1 → count = 1
        local b = data.files["/project/src/baz.lua"].branches[2][1]
        assert.equals(1, b.count)
    end)

    it("stores zero count for untaken branches", function()
        local data = util.lcov_to_table(fixture("branches.lcov"))
        -- BRDA:2,0,1,0 → count = 0
        local b = data.files["/project/src/baz.lua"].branches[2][2]
        assert.equals(0, b.count)
    end)

    it("stores all branches for fully covered lines", function()
        local data = util.lcov_to_table(fixture("branches.lcov"))
        -- BRDA:3,1,0,1 and BRDA:3,1,1,1 — both taken
        assert.equals(2, #data.files["/project/src/baz.lua"].branches[3])
    end)

    it("still populates partial_lines for sign building", function()
        local data = util.lcov_to_table(fixture("branches.lcov"))
        local baz = data.files["/project/src/baz.lua"]
        assert.equals(1, #baz.partial_lines)
        assert.equals(2, baz.partial_lines[1][1])
    end)
end)
