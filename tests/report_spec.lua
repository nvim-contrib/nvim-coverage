-- Tests for report.lua (coverage data cache)

local report = require("coverage.cache")

local mock_data = {
    files = {},
    totals = { num_statements = 10, covered_lines = 8, missing_lines = 2,
               excluded_lines = 0, percent_covered = 80.0 },
}
local mock_file = "/tmp/test-lcov.info"

describe("report", function()
    before_each(function()
        report.clear()
    end)

    describe("initial state", function()
        it("is_cached returns false", function()
            assert.is_false(report.is_cached())
        end)

        it("get returns nil", function()
            assert.is_nil(report.get())
        end)
    end)

    describe("set", function()
        it("stores the data", function()
            report.set(mock_data, mock_file)
            assert.equals(mock_data, report.get())
        end)

        it("stores the file path", function()
            report.set(mock_data, mock_file)
            assert.equals(mock_file, report.get_file())
        end)

        it("marks as cached", function()
            report.set(mock_data, mock_file)
            assert.is_true(report.is_cached())
        end)
    end)

    describe("clear", function()
        it("removes cached data", function()
            report.set(mock_data, mock_file)
            report.clear()
            assert.is_nil(report.get())
        end)

        it("marks as not cached", function()
            report.set(mock_data, mock_file)
            report.clear()
            assert.is_false(report.is_cached())
        end)

        it("clears the file path", function()
            report.set(mock_data, mock_file)
            report.clear()
            assert.is_nil(report.get_file())
        end)
    end)
end)
