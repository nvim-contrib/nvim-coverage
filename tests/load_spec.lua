-- Tests for coverage.load() file resolution (issue #7)

local coverage = require("coverage")
local config   = require("coverage.config")

local fixture = function(name)
    return vim.fn.getcwd() .. "/tests/fixtures/" .. name
end

local nonexistent = "/tmp/does-not-exist-nvim-coverage.lcov"

describe("coverage.load file resolution", function()
    before_each(function()
        config.opts = {}
        config.setup()
    end)

    describe("string path", function()
        it("loads when file exists", function()
            assert.has_no.errors(function()
                coverage.load(fixture("simple.lcov"))
            end)
        end)

        it("notifies and returns when file does not exist", function()
            local notified = false
            local orig = vim.notify
            vim.notify = function() notified = true end
            coverage.load(nonexistent)
            vim.notify = orig
            assert.is_true(notified)
        end)
    end)

    describe("list of paths", function()
        it("uses first existing path", function()
            local loaded_file = nil
            -- spy: intercept watch.start to capture resolved path
            local watch = require("coverage.watch")
            local orig = watch.start
            watch.start = function(f, _) loaded_file = f end

            coverage.load({ nonexistent, fixture("simple.lcov") })

            watch.start = orig
            assert.equals(fixture("simple.lcov"), loaded_file)
        end)

        it("notifies when no path in list exists", function()
            local notified = false
            local orig = vim.notify
            vim.notify = function() notified = true end
            coverage.load({ nonexistent, nonexistent .. ".2" })
            vim.notify = orig
            assert.is_true(notified)
        end)

        it("skips non-existing paths and finds the first match", function()
            local loaded_file = nil
            local watch = require("coverage.watch")
            local orig = watch.start
            watch.start = function(f, _) loaded_file = f end

            coverage.load({
                nonexistent,
                nonexistent .. ".2",
                fixture("simple.lcov"),
                fixture("branches.lcov"),  -- should not reach this
            })

            watch.start = orig
            assert.equals(fixture("simple.lcov"), loaded_file)
        end)
    end)

    describe("config.opts.file fallback", function()
        it("falls back to string file", function()
            local loaded_file = nil
            local watch = require("coverage.watch")
            local orig = watch.start
            watch.start = function(f, _) loaded_file = f end

            config.opts.file = fixture("simple.lcov")
            coverage.load()

            watch.start = orig
            assert.equals(fixture("simple.lcov"), loaded_file)
        end)

        it("falls back to list file", function()
            local loaded_file = nil
            local watch = require("coverage.watch")
            local orig = watch.start
            watch.start = function(f, _) loaded_file = f end

            config.opts.file = { nonexistent, fixture("simple.lcov") }
            coverage.load()

            watch.start = orig
            assert.equals(fixture("simple.lcov"), loaded_file)
        end)
    end)
end)
