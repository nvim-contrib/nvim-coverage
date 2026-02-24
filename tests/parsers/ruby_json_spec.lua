local ruby_json = require("coverage.parsers.ruby_json")
local Path = require("plenary.path")

describe("ruby_json parser", function()
    local fixture = Path:new(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/fixtures/simplecov.json")

    it("classifies executed lines (>0)", function()
        local data = ruby_json.parse(fixture)
        assert.is_not_nil(data)
        local app = data.files["/project/lib/app.rb"]
        assert.is_not_nil(app)
        -- lines: [1, 1, null, 0, 3, null] → executed: 1, 2, 5
        assert.truthy(vim.tbl_contains(app.executed_lines, 1))
        assert.truthy(vim.tbl_contains(app.executed_lines, 2))
        assert.truthy(vim.tbl_contains(app.executed_lines, 5))
    end)

    it("classifies missing lines (==0)", function()
        local data = ruby_json.parse(fixture)
        local app = data.files["/project/lib/app.rb"]
        -- line 4 = 0 → missing
        assert.truthy(vim.tbl_contains(app.missing_lines, 4))
    end)

    it("classifies excluded lines (null/vim.NIL)", function()
        local data = ruby_json.parse(fixture)
        local app = data.files["/project/lib/app.rb"]
        -- lines 3 and 6 are null → excluded
        assert.truthy(vim.tbl_contains(app.excluded_lines, 3))
        assert.truthy(vim.tbl_contains(app.excluded_lines, 6))
        assert.equals(2, app.summary.excluded_lines)
    end)

    it("counts statements correctly (excludes nil lines)", function()
        local data = ruby_json.parse(fixture)
        local app = data.files["/project/lib/app.rb"]
        -- [1,1,nil,0,3,nil]: 3 executed + 1 missing = 4 statements
        assert.equals(4, app.summary.num_statements)
        assert.equals(3, app.summary.covered_lines)
        assert.equals(1, app.summary.missing_lines)
    end)

    it("handles util.rb", function()
        local data = ruby_json.parse(fixture)
        local util = data.files["/project/lib/util.rb"]
        assert.is_not_nil(util)
        -- [2, 0, 1] → executed: 1, 3; missing: 2
        assert.truthy(vim.tbl_contains(util.executed_lines, 1))
        assert.truthy(vim.tbl_contains(util.missing_lines, 2))
        assert.truthy(vim.tbl_contains(util.executed_lines, 3))
    end)

    it("returns CoverageData structure", function()
        local data = ruby_json.parse(fixture)
        assert.is_not_nil(data.meta)
        assert.is_not_nil(data.totals)
        assert.is_not_nil(data.files)
    end)

    it("computes correct totals", function()
        local data = ruby_json.parse(fixture)
        -- app: 4 stmts, 3 covered; util: 3 stmts, 2 covered
        assert.equals(7, data.totals.num_statements)
        assert.equals(5, data.totals.covered_lines)
        assert.equals(2, data.totals.missing_lines)
    end)
end)
