-- Tests for virtual_text.lua (extmark placement from CoverageData)

local config       = require("coverage.config")
local virtual_text = require("coverage.virtual_text")

config.setup()

local fname = "/project/src/vt.lua"

local make_data = function(hit_counts)
    return {
        files = {
            [fname] = {
                executed_lines   = {},
                missing_lines    = {},
                missing_branches = {},
                hit_counts       = hit_counts or {},
            },
        },
        totals = {},
    }
end

describe("virtual_text", function()
    local bufnr

    before_each(function()
        bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(bufnr, fname)
        -- add enough lines so extmarks on line 3 are valid
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "", "", "", "", "" })
        virtual_text.clear()
    end)

    after_each(function()
        virtual_text.clear()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("is disabled by default", function()
        assert.is_false(virtual_text.is_enabled())
    end)

    it("place enables virtual text", function()
        virtual_text.place(make_data({ [1] = 5 }))
        assert.is_true(virtual_text.is_enabled())
    end)

    it("clear disables virtual text", function()
        virtual_text.place(make_data({ [1] = 5 }))
        virtual_text.clear()
        assert.is_false(virtual_text.is_enabled())
    end)

    it("places an extmark for each line with a hit count", function()
        virtual_text.place(make_data({ [1] = 10, [3] = 0 }))
        local ns = vim.api.nvim_get_namespaces()["coverage_virtual_text"]
        assert.is_not_nil(ns)
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
        assert.equals(2, #marks)
    end)

    it("skips files not open in a buffer", function()
        local data = {
            files = {
                ["/not/open/file.lua"] = {
                    executed_lines = {}, missing_lines = {}, missing_branches = {},
                    hit_counts = { [1] = 5 },
                },
            },
            totals = {},
        }
        virtual_text.place(data)
        -- no error, but no marks placed either (buffer not open)
        assert.is_true(virtual_text.is_enabled())
    end)

    it("formats the virtual text as '× <count>'", function()
        virtual_text.place(make_data({ [1] = 42 }))
        local ns = vim.api.nvim_get_namespaces()["coverage_virtual_text"]
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
        assert.equals(1, #marks)
        local virt = marks[1][4].virt_text
        assert.equals("× 42", virt[1][1])
    end)
end)
