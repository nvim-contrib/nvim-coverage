-- Tests for util.lua (lcov parser)

local Path = require("plenary.path")
local util = require("coverage.util")

local fixture = function(name)
    return Path:new(vim.fn.getcwd() .. "/spec/fixtures/" .. name)
end

describe("util.lcov_to_table", function()
    describe("simple lcov file", function()
        local data

        before_each(function()
            data = util.lcov_to_table(fixture("simple.lcov"))
        end)

        it("returns a CoverageData table", function()
            assert.is_table(data)
            assert.is_table(data.files)
            assert.is_table(data.totals)
        end)

        it("parses both source files", function()
            assert.is_table(data.files["/project/src/foo.lua"])
            assert.is_table(data.files["/project/src/bar.lua"])
        end)

        it("records executed lines", function()
            local foo = data.files["/project/src/foo.lua"]
            assert.same({ 1, 3 }, foo.covered_lines)
        end)

        it("records missing lines", function()
            local foo = data.files["/project/src/foo.lua"]
            assert.same({ 2, 4 }, foo.uncovered_lines)
        end)

        it("records covered_lines from LH", function()
            local foo = data.files["/project/src/foo.lua"]
            assert.equals(2, foo.summary.covered_lines)
        end)

        it("records num_statements from LF", function()
            local foo = data.files["/project/src/foo.lua"]
            assert.equals(4, foo.summary.num_statements)
        end)

        it("calculates percent_covered per file", function()
            local foo = data.files["/project/src/foo.lua"]
            assert.equals(50, foo.summary.percent_covered)
        end)

        it("calculates fully covered file", function()
            local bar = data.files["/project/src/bar.lua"]
            assert.equals(100, bar.summary.percent_covered)
        end)

        it("records hit counts for all DA lines", function()
            local foo = data.files["/project/src/foo.lua"]
            assert.equals(1, foo.hit_counts[1])
            assert.equals(0, foo.hit_counts[2])
            assert.equals(1, foo.hit_counts[3])
            assert.equals(0, foo.hit_counts[4])
        end)

        it("aggregates totals", function()
            assert.equals(7, data.totals.num_statements)
            assert.equals(5, data.totals.covered_lines)
            assert.equals(2, data.totals.uncovered_lines)
        end)

        it("calculates total percent_covered", function()
            assert.is_near(71.43, data.totals.percent_covered, 0.01)
        end)
    end)

    describe("lcov file with branch coverage", function()
        local data

        before_each(function()
            data = util.lcov_to_table(fixture("branches.lcov"))
        end)

        local baz = function() return data.files["/project/src/baz.lua"] end

        it("records num_branches from BRF", function()
            assert.equals(4, baz().summary.num_branches)
        end)

        it("records num_partial_branches from BRH", function()
            -- BRF=4, BRH=3 => 1 partial branch
            assert.equals(1, baz().summary.num_partial_branches)
        end)

        it("records missing branches", function()
            -- BRDA:2,0,1,0 => line 2, branch not taken
            local branches = baz().partial_lines
            assert.equals(1, #branches)
            assert.equals(2, branches[1][1])
        end)
    end)

    describe("empty lcov file", function()
        it("handles zero statements without error", function()
            -- LF:0 would cause division by zero — should not crash
            assert.has_no.errors(function()
                util.lcov_to_table(fixture("empty.lcov"))
            end)
        end)
    end)
end)
