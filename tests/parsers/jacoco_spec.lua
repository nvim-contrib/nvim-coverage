local jacoco = require("coverage.parsers.jacoco")
local Path = require("plenary.path")

describe("jacoco parser", function()
    local fixture_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/fixtures"
    local fixture = Path:new(fixture_dir .. "/jacoco.xml")

    -- dir_prefix must end with / and match package path
    local dir_prefix = fixture_dir .. "/java/"

    it("classifies covered lines correctly", function()
        local data = jacoco.parse(fixture, dir_prefix)
        assert.is_not_nil(data)
        assert.is_not_nil(data.files)
        local key = nil
        for k, _ in pairs(data.files) do
            if k:match("Main%.java$") then
                key = k
                break
            end
        end
        assert.is_not_nil(key, "Main.java not found in parsed files")
        local file = data.files[key]
        -- Line 3: ci=1, mi=0, cb=0, mb=0 → covered
        assert.truthy(vim.tbl_contains(file.executed_lines, 3))
        assert.falsy(vim.tbl_contains(file.missing_lines, 3))
    end)

    it("classifies partial lines (mb=1, cb=1) as executed with missing branch", function()
        local data = jacoco.parse(fixture, dir_prefix)
        local key = nil
        for k, _ in pairs(data.files) do
            if k:match("Main%.java$") then key = k; break end
        end
        local file = data.files[key]
        -- Line 5: mi=0, ci=1, mb=1, cb=1 → partial
        assert.truthy(vim.tbl_contains(file.executed_lines, 5))
        local branch_lines = {}
        for _, b in ipairs(file.missing_branches) do
            table.insert(branch_lines, b[1])
        end
        assert.truthy(vim.tbl_contains(branch_lines, 5))
    end)

    it("classifies missed lines correctly", function()
        local data = jacoco.parse(fixture, dir_prefix)
        local key = nil
        for k, _ in pairs(data.files) do
            if k:match("Main%.java$") then key = k; break end
        end
        local file = data.files[key]
        -- Line 7: mi=1, ci=0 → missed
        assert.truthy(vim.tbl_contains(file.missing_lines, 7))
        assert.falsy(vim.tbl_contains(file.executed_lines, 7))
    end)

    it("returns CoverageData structure", function()
        local data = jacoco.parse(fixture, dir_prefix)
        assert.is_not_nil(data.meta)
        assert.is_not_nil(data.totals)
        assert.is_not_nil(data.files)
    end)

    it("computes correct totals", function()
        local data = jacoco.parse(fixture, dir_prefix)
        -- 3 lines: 2 covered/partial + 1 missed
        assert.equals(3, data.totals.num_statements)
        assert.equals(2, data.totals.covered_lines)
        assert.equals(1, data.totals.missing_lines)
    end)

    it("includes branch totals from report counters", function()
        local data = jacoco.parse(fixture, dir_prefix)
        -- BRANCH counter: missed=1, covered=1 → num_branches=2, num_partial=1
        assert.equals(2, data.totals.num_branches)
        assert.equals(1, data.totals.num_partial_branches)
    end)
end)
