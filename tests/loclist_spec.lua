-- Tests for loclist.lua

local config  = require("coverage.config")
local report  = require("coverage.cache")
local ll      = require("coverage.loclist")

config.setup()

local fname = "/project/src/ll.lua"

local make_data = function(file)
    return { files = { [fname] = file }, totals = {} }
end

describe("loclist", function()
    local bufnr

    before_each(function()
        report.clear()
        bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(bufnr, fname)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "line one", "line two", "line three", "line four", "line five",
        })
        vim.api.nvim_set_current_buf(bufnr)
    end)

    after_each(function()
        report.clear()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("notifies when no report is cached", function()
        local notified = false
        local orig = vim.notify
        vim.notify = function() notified = true end
        ll.populate()
        vim.notify = orig
        assert.is_true(notified)
    end)

    it("notifies when no data for current file", function()
        report.set({ files = {}, totals = {} })
        local notified = false
        local orig = vim.notify
        vim.notify = function() notified = true end
        ll.populate()
        vim.notify = orig
        assert.is_true(notified)
    end)

    it("populates loclist with uncovered lines by default", function()
        report.set(make_data({
            covered_lines   = { 1 },
            uncovered_lines = { 2, 4 },
            partial_lines   = {},
            summary         = { percent_covered = 50 },
        }))
        ll.populate()
        local items = vim.fn.getloclist(0)
        assert.equals(2, #items)
    end)

    it("populates loclist with partial lines when requested", function()
        report.set(make_data({
            covered_lines   = { 1 },
            uncovered_lines = {},
            partial_lines   = { { 3, -1 }, { 5, -1 } },
            summary         = { percent_covered = 80 },
        }))
        ll.populate("partial")
        local items = vim.fn.getloclist(0)
        assert.equals(2, #items)
    end)

    it("includes line content from open buffer", function()
        report.set(make_data({
            covered_lines   = {},
            uncovered_lines = { 2 },
            partial_lines   = {},
            summary         = { percent_covered = 0 },
        }))
        ll.populate()
        local items = vim.fn.getloclist(0)
        assert.equals(1, #items)
        assert.equals("line two", items[1].text)
    end)

    it("sorts lines in ascending order", function()
        report.set(make_data({
            covered_lines   = {},
            uncovered_lines = { 5, 1, 3 },
            partial_lines   = {},
            summary         = { percent_covered = 0 },
        }))
        ll.populate()
        local items = vim.fn.getloclist(0)
        assert.equals(3, #items)
        assert.equals(1, items[1].lnum)
        assert.equals(3, items[2].lnum)
        assert.equals(5, items[3].lnum)
    end)
end)
