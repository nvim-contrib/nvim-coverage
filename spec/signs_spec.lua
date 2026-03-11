-- Tests for signs.lua (sign building from CoverageData)

local config = require("coverage.config")
local signs  = require("coverage.signs")

-- Minimal setup so sign_group and priorities are available
config.setup()

local make_data = function(opts)
    opts = opts or {}
    return {
        files = {
            ["/project/src/foo.lua"] = {
                executed_lines   = opts.executed   or {},
                missing_lines    = opts.missing    or {},
                missing_branches = opts.branches   or {},
            },
        },
        totals = {},
    }
end

describe("signs.build", function()
    -- bufnr returns -1 for files not open in neovim, so build returns an
    -- empty list. We test the logic by opening a scratch buffer.

    local bufnr
    local fname = "/project/src/foo.lua"

    before_each(function()
        bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(bufnr, fname)
    end)

    after_each(function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("returns empty list when no lines", function()
        local list = signs.build(make_data())
        assert.same({}, list)
    end)

    it("creates covered signs for executed lines", function()
        local list = signs.build(make_data({ executed = { 1, 3 } }))
        assert.equals(2, #list)
        assert.equals("coverage_covered", list[1].name)
        assert.equals("coverage_covered", list[2].name)
    end)

    it("creates uncovered signs for missing lines", function()
        local list = signs.build(make_data({ missing = { 2, 4 } }))
        assert.equals(2, #list)
        assert.equals("coverage_uncovered", list[1].name)
    end)

    it("creates partial signs for lines with missing branches", function()
        -- line 2 executed but has a missing branch -> partial
        local list = signs.build(make_data({
            executed = { 1, 2 },
            branches = { { 2, -1 } },
        }))
        local names = vim.tbl_map(function(s) return s.name end, list)
        assert.is_true(vim.tbl_contains(names, "coverage_covered"))
        assert.is_true(vim.tbl_contains(names, "coverage_partial"))
        assert.is_false(vim.tbl_contains(names, "coverage_uncovered"))
    end)

    it("does not create covered sign for a line that is only partially covered", function()
        local list = signs.build(make_data({
            executed = { 5 },
            branches = { { 5, -1 } },
        }))
        local names = vim.tbl_map(function(s) return s.name end, list)
        assert.is_false(vim.tbl_contains(names, "coverage_covered"))
        assert.is_true(vim.tbl_contains(names, "coverage_partial"))
    end)

    it("skips files not open in a buffer", function()
        local data = {
            files = {
                ["/not/open/file.lua"] = {
                    executed_lines = { 1, 2 }, missing_lines = {}, missing_branches = {},
                },
            },
            totals = {},
        }
        local list = signs.build(data)
        assert.same({}, list)
    end)
end)
