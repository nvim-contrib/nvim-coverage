local lcov = require("coverage.parsers.lcov")
local Path = require("plenary.path")

describe("lcov parser", function()
    local fixture = Path:new(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/fixtures/sample.lcov")

    it("parses executed and missing lines", function()
        local data = lcov.parse(fixture)
        assert.is_not_nil(data)
        assert.is_not_nil(data.files)
        local main = data.files["/project/src/main.lua"]
        assert.is_not_nil(main)
        assert.truthy(vim.tbl_contains(main.executed_lines, 1))
        assert.truthy(vim.tbl_contains(main.executed_lines, 3))
        assert.truthy(vim.tbl_contains(main.missing_lines, 2))
        assert.truthy(vim.tbl_contains(main.missing_lines, 4))
    end)

    it("parses missing branches", function()
        local data = lcov.parse(fixture)
        local main = data.files["/project/src/main.lua"]
        assert.is_not_nil(main.missing_branches)
        assert.equals(1, #main.missing_branches)
        assert.equals(3, main.missing_branches[1][1])
    end)

    it("computes per-file summary", function()
        local data = lcov.parse(fixture)
        local main = data.files["/project/src/main.lua"]
        assert.equals(2, main.summary.covered_lines)
        assert.equals(4, main.summary.num_statements)
        assert.equals(2, main.summary.missing_lines)
    end)

    it("computes totals", function()
        local data = lcov.parse(fixture)
        -- main: 4 stmts, 2 covered; util: 3 stmts, 2 covered → 7 total, 4 covered
        assert.equals(7, data.totals.num_statements)
        assert.equals(4, data.totals.covered_lines)
        assert.equals(3, data.totals.missing_lines)
    end)

    it("handles multiple files", function()
        local data = lcov.parse(fixture)
        assert.is_not_nil(data.files["/project/src/util.lua"])
    end)

    it("returns CoverageData structure", function()
        local data = lcov.parse(fixture)
        assert.is_not_nil(data.meta)
        assert.is_not_nil(data.totals)
        assert.is_not_nil(data.files)
    end)
end)
