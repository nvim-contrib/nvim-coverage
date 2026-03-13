--- Go neotest consumer that converts coverage.out to lcov after tests finish,
--- then reloads coverage. Requires `go tool cover` to be available.
---
--- Expects tests to be run with `-coverprofile=coverage.out` (e.g. via ginkgo
--- or neotest-go/neotest-golang with coverage flags enabled).
---
--- After tests finish the consumer globs for all `**/coverage.out` files under
--- cwd, converts each to lcov via `go tool cover`, concatenates the results
--- into `cwd/coverage/lcov.info`, and loads the merged file.
---
--- Usage:
---   require("neotest").setup({
---     consumers = {
---       coverage_go = require("coverage.neotest.go"),
---     },
---   })
---
--- @type fun(client: table): table
local consumer = function(client)
    client.listeners.results = function(_, _, partial)
        if partial then return end

        local cwd = vim.fn.getcwd()
        local profiles = vim.fn.glob(cwd .. "/**/coverage.out", true, true)
        if #profiles == 0 then return end

        local lcov_dir = cwd .. "/coverage"
        local lcov_out = lcov_dir .. "/lcov.info"
        vim.fn.mkdir(lcov_dir, "p")

        -- Convert each coverage.out to lcov synchronously and concatenate.
        local merged = {}
        for _, profile in ipairs(profiles) do
            local tmp = vim.fn.tempname()
            vim.fn.system({ "go", "tool", "cover", "-o", tmp, profile })
            if vim.v.shell_error == 0 then
                local contents = vim.fn.readfile(tmp)
                for _, line in ipairs(contents) do
                    merged[#merged + 1] = line
                end
            end
            vim.fn.delete(tmp)
        end

        if #merged == 0 then return end

        vim.fn.writefile(merged, lcov_out)
        vim.schedule(function()
            require("coverage").load(lcov_out, require("coverage.signs").is_enabled())
        end)
    end
    return {}
end

return consumer
