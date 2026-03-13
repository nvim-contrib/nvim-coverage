-- Tests for the Go neotest consumer's gcov_to_lcov converter.

local consumer = require("coverage.neotest.go")
local gcov_to_lcov = consumer._gcov_to_lcov

local fixture_dir = vim.fn.getcwd() .. "/tests/fixtures/"

describe("gcov_to_lcov", function()
    describe("single profile", function()
        local result

        before_each(function()
            result = gcov_to_lcov({ fixture_dir .. "coverage_single.out" })
        end)

        it("produces lcov output", function()
            assert.is_true(#result > 0)
        end)

        it("emits SF records for each source file", function()
            local sf_lines = vim.tbl_filter(function(l) return l:match("^SF:") end, result)
            assert.equals(2, #sf_lines)
        end)

        it("expands line ranges into DA records", function()
            -- foo.go:10.2,12.5 => lines 10,11,12 with count 1
            local found = {}
            for _, l in ipairs(result) do
                local line, count = l:match("^DA:(%d+),(%d+)")
                if line then
                    found[tonumber(line)] = tonumber(count)
                end
            end
            -- Lines 10-12 from the first foo.go range
            assert.equals(1, found[10])
            assert.equals(1, found[11])
            assert.equals(1, found[12])
        end)

        it("records uncovered lines with count 0", function()
            -- foo.go:14.2,16.5 => lines 14,15,16 with count 0
            -- Find DA records after the foo.go SF record
            local in_foo = false
            local foo_lines = {}
            for _, l in ipairs(result) do
                if l == "SF:github.com/user/pkg/foo.go" then
                    in_foo = true
                elseif l:match("^SF:") then
                    in_foo = false
                elseif in_foo then
                    local line, count = l:match("^DA:(%d+),(%d+)")
                    if line then
                        foo_lines[tonumber(line)] = tonumber(count)
                    end
                end
            end
            assert.equals(0, foo_lines[14])
            assert.equals(0, foo_lines[15])
            assert.equals(0, foo_lines[16])
        end)

        it("emits correct LF and LH for bar.go", function()
            local in_bar = false
            local lf, lh
            for _, l in ipairs(result) do
                if l == "SF:github.com/user/pkg/bar.go" then
                    in_bar = true
                elseif l == "end_of_record" and in_bar then
                    break
                elseif in_bar then
                    local val = l:match("^LF:(%d+)")
                    if val then lf = tonumber(val) end
                    val = l:match("^LH:(%d+)")
                    if val then lh = tonumber(val) end
                end
            end
            -- bar.go:5.1,7.3 => lines 5,6,7 all with count 3
            assert.equals(3, lf)
            assert.equals(3, lh)
        end)

        it("ends each file with end_of_record", function()
            local eor = vim.tbl_filter(function(l) return l == "end_of_record" end, result)
            assert.equals(2, #eor)
        end)
    end)

    describe("multi-profile merging", function()
        local result

        before_each(function()
            result = gcov_to_lcov({
                fixture_dir .. "coverage_single.out",
                fixture_dir .. "coverage_extra.out",
            })
        end)

        it("sums counts for overlapping lines", function()
            -- foo.go lines 10-12: count 1 from single + count 2 from extra = 3
            local in_foo = false
            local foo_lines = {}
            for _, l in ipairs(result) do
                if l == "SF:github.com/user/pkg/foo.go" then
                    in_foo = true
                elseif l:match("^SF:") then
                    in_foo = false
                elseif in_foo then
                    local line, count = l:match("^DA:(%d+),(%d+)")
                    if line then
                        foo_lines[tonumber(line)] = tonumber(count)
                    end
                end
            end
            assert.equals(3, foo_lines[10])
            assert.equals(3, foo_lines[11])
            assert.equals(3, foo_lines[12])
        end)

        it("includes lines from both profiles for bar.go", function()
            local in_bar = false
            local bar_lines = {}
            for _, l in ipairs(result) do
                if l == "SF:github.com/user/pkg/bar.go" then
                    in_bar = true
                elseif l:match("^SF:") then
                    in_bar = false
                elseif in_bar then
                    local line, count = l:match("^DA:(%d+),(%d+)")
                    if line then
                        bar_lines[tonumber(line)] = tonumber(count)
                    end
                end
            end
            -- From single: lines 5,6,7 count 3; from extra: lines 8,9 count 1
            assert.equals(3, bar_lines[5])
            assert.equals(1, bar_lines[8])
            assert.equals(1, bar_lines[9])
        end)
    end)

    describe("empty input", function()
        it("returns empty table for no profiles", function()
            assert.same({}, gcov_to_lcov({}))
        end)
    end)
end)
