-- Tests for quickfix.lua

local config  = require("coverage.config")
local report  = require("coverage.report")
local qf      = require("coverage.quickfix")

config.setup()

local make_data = function(files)
    return { files = files, totals = {} }
end

local make_file = function(covered, uncovered, partial, pct)
    return {
        covered_lines   = covered   or {},
        uncovered_lines = uncovered or {},
        partial_lines   = partial   or {},
        summary = { percent_covered = pct or 100 },
    }
end

describe("quickfix", function()
    before_each(function()
        report.clear()
        vim.fn.setqflist({}, "r", { items = {} })
    end)

    after_each(function()
        report.clear()
    end)

    it("notifies when no report is cached", function()
        local notified = false
        local orig = vim.notify
        vim.notify = function() notified = true end
        qf.populate()
        vim.notify = orig
        assert.is_true(notified)
    end)

    it("populates quickfix with all files", function()
        report.set(make_data({
            ["/a.lua"] = make_file({1,2}, {3}, {}, 75),
            ["/b.lua"] = make_file({1},   {},  {}, 100),
        }))
        qf.populate()
        local items = vim.fn.getqflist()
        assert.equals(2, #items)
    end)

    it("filters to only uncovered files", function()
        report.set(make_data({
            ["/a.lua"] = make_file({1}, {2,3}, {}, 50),
            ["/b.lua"] = make_file({1}, {},    {}, 100),
        }))
        qf.populate("uncovered")
        local items = vim.fn.getqflist()
        assert.equals(1, #items)
    end)

    it("sorts by coverage ascending", function()
        report.set(make_data({
            ["/a.lua"] = make_file({}, {1}, {}, 80),
            ["/b.lua"] = make_file({}, {1}, {}, 40),
            ["/c.lua"] = make_file({}, {1}, {}, 60),
        }))
        qf.populate()
        local items = vim.fn.getqflist()
        assert.equals(3, #items)
        -- worst first: 40%, 60%, 80%
        assert.is_true(items[1].text:match("40%%") ~= nil)
        assert.is_true(items[2].text:match("60%%") ~= nil)
        assert.is_true(items[3].text:match("80%%") ~= nil)
    end)

    it("shows 100% text for fully covered files", function()
        report.set(make_data({
            ["/a.lua"] = make_file({1,2}, {}, {}, 100),
        }))
        qf.populate()
        local items = vim.fn.getqflist()
        assert.equals(1, #items)
        assert.equals("100%", items[1].text)
    end)
end)
