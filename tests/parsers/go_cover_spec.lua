local go_cover = require("coverage.parsers.go_cover")
local Path = require("plenary.path")

describe("go_cover parser", function()
    local fixture = Path:new(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/fixtures/sample.coverprofile")

    it("parses executed line ranges", function()
        local data = go_cover.parse(fixture)
        assert.is_not_nil(data)
        assert.is_not_nil(data.files)
        -- Without a go.mod in test context, module prefix is not stripped
        -- Find the main.go entry (key may include module prefix or just path)
        local main_key = nil
        for k, _ in pairs(data.files) do
            if k:match("main%.go$") then
                main_key = k
                break
            end
        end
        assert.is_not_nil(main_key, "main.go not found in parsed files")
        local main = data.files[main_key]
        -- Lines 3-5 are covered (count=1), lines 7-9 are missing (count=0)
        assert.truthy(vim.tbl_contains(main.executed_lines, 3))
        assert.truthy(vim.tbl_contains(main.executed_lines, 4))
        assert.truthy(vim.tbl_contains(main.executed_lines, 5))
        assert.truthy(vim.tbl_contains(main.missing_lines, 7))
        assert.truthy(vim.tbl_contains(main.missing_lines, 8))
        assert.truthy(vim.tbl_contains(main.missing_lines, 9))
    end)

    it("parses util.go coverage", function()
        local data = go_cover.parse(fixture)
        local util_key = nil
        for k, _ in pairs(data.files) do
            if k:match("util%.go$") then
                util_key = k
                break
            end
        end
        assert.is_not_nil(util_key, "util.go not found in parsed files")
        local util_file = data.files[util_key]
        assert.truthy(vim.tbl_contains(util_file.executed_lines, 1))
        assert.truthy(vim.tbl_contains(util_file.executed_lines, 2))
        assert.truthy(vim.tbl_contains(util_file.executed_lines, 3))
        assert.truthy(vim.tbl_contains(util_file.missing_lines, 5))
        assert.truthy(vim.tbl_contains(util_file.missing_lines, 6))
    end)

    it("returns CoverageData structure", function()
        local data = go_cover.parse(fixture)
        assert.is_not_nil(data.meta)
        assert.is_not_nil(data.totals)
        assert.is_not_nil(data.files)
    end)

    it("computes correct totals", function()
        local data = go_cover.parse(fixture)
        -- main.go: 3 covered (3,4,5) + 3 missing (7,8,9) = 6 stmts
        -- util.go: 3 covered (1,2,3) + 2 missing (5,6) = 5 stmts
        -- total: 11 stmts, 6 covered
        assert.equals(11, data.totals.num_statements)
        assert.equals(6, data.totals.covered_lines)
    end)
end)
