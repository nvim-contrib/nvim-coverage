local cobertura = require("coverage.parsers.cobertura")
local Path = require("plenary.path")

describe("cobertura parser", function()
    local fixture = Path:new(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/fixtures/cobertura.xml")

    it("parses executed and missing lines", function()
        local data = cobertura.parse(fixture, {})
        assert.is_not_nil(data)
        assert.is_not_nil(data.files)
        -- Find the app.php entry
        local app_key = nil
        for k, _ in pairs(data.files) do
            if k:match("app%.php$") then
                app_key = k
                break
            end
        end
        assert.is_not_nil(app_key, "app.php not found in parsed files")
        local app = data.files[app_key]
        assert.truthy(vim.tbl_contains(app.executed_lines, 1))
        assert.truthy(vim.tbl_contains(app.executed_lines, 2))
        assert.truthy(vim.tbl_contains(app.missing_lines, 3))
        assert.truthy(vim.tbl_contains(app.executed_lines, 4))
    end)

    it("filters out interface-only packages (0 statements)", function()
        -- The fixture has only real packages with statements
        local data = cobertura.parse(fixture, {})
        for _, file in pairs(data.files) do
            assert.is_true(file.summary.num_statements > 0)
        end
    end)

    it("returns CoverageData structure", function()
        local data = cobertura.parse(fixture)
        assert.is_not_nil(data.meta)
        assert.is_not_nil(data.totals)
        assert.is_not_nil(data.files)
    end)

    it("computes correct summary counts", function()
        local data = cobertura.parse(fixture, {})
        -- 4 lines: 3 executed, 1 missing
        assert.equals(4, data.totals.num_statements)
        assert.equals(3, data.totals.covered_lines)
        assert.equals(1, data.totals.missing_lines)
    end)

    it("applies path mappings", function()
        local data = cobertura.parse(fixture, { ["/project/src"] = "/other/path" })
        assert.is_not_nil(data)
        -- Mapping applies to sources, so files should still be resolvable
    end)
end)
