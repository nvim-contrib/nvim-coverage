local swift_json = require("coverage.parsers.swift_json")
local Path = require("plenary.path")

describe("swift_json parser", function()
    local fixture = Path:new(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/fixtures/swift_coverage.json")

    local function load_fixture()
        local ok, data = pcall(vim.fn.json_decode, fixture:read())
        assert.is_true(ok, "Failed to decode swift fixture JSON")
        return swift_json.parse_table(data)
    end

    it("parses file entries", function()
        local data = load_fixture()
        assert.is_not_nil(data)
        assert.is_not_nil(data.files)
        -- The fixture has /project/Sources/App/main.swift
        local key = "/project/Sources/App/main.swift"
        assert.is_not_nil(data.files[key], "main.swift not found in parsed files")
    end)

    it("uses JSON summary counts for statements and coverage", function()
        local data = load_fixture()
        local file = data.files["/project/Sources/App/main.swift"]
        -- summary.lines: count=3, covered=2
        assert.equals(3, file.summary.num_statements)
        assert.equals(2, file.summary.covered_lines)
        assert.equals(1, file.summary.missing_lines)
    end)

    it("walks segments to populate executed and missing lines", function()
        local data = load_fixture()
        local file = data.files["/project/Sources/App/main.swift"]
        -- Segment [1,1,3,true,...] to [2,1,...] → line 1 covered (count=3)
        -- Segment [2,1,0,true,...] to [3,1,...] → line 2 missing (count=0)
        -- Segment [3,1,5,true,...] to [4,1,...] → line 3 covered (count=5)
        assert.truthy(vim.tbl_contains(file.executed_lines, 1))
        assert.truthy(vim.tbl_contains(file.missing_lines, 2))
        assert.truthy(vim.tbl_contains(file.executed_lines, 3))
    end)

    it("returns CoverageData structure", function()
        local data = load_fixture()
        assert.is_not_nil(data.meta)
        assert.is_not_nil(data.totals)
        assert.is_not_nil(data.files)
    end)

    it("computes correct totals", function()
        local data = load_fixture()
        assert.equals(3, data.totals.num_statements)
        assert.equals(2, data.totals.covered_lines)
        assert.equals(1, data.totals.missing_lines)
    end)

    it("skips .build/ files", function()
        local build_data = {
            data = {
                {
                    files = {
                        {
                            filename = "/project/.build/checkouts/dep/src.swift",
                            segments = {},
                            summary = { lines = { count = 5, covered = 5, percent = 100 } }
                        }
                    },
                    totals = { lines = { count = 5, covered = 5, percent = 100 } }
                }
            }
        }
        local data = swift_json.parse_table(build_data)
        assert.equals(0, vim.tbl_count(data.files))
    end)
end)
