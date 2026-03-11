--- Go neotest consumer that converts coverage.out to lcov after tests finish,
--- then reloads coverage. Requires `go tool cover` to be available.
---
--- Expects tests to be run with `-coverprofile=coverage.out` (e.g. via ginkgo
--- or neotest-go/neotest-golang with coverage flags enabled).
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

        local cwd          = vim.fn.getcwd()
        local coverprofile = cwd .. "/coverage.out"
        local lcov_out     = cwd .. "/coverage/lcov.info"

        if vim.fn.filereadable(coverprofile) ~= 1 then return end

        vim.fn.mkdir(cwd .. "/coverage", "p")
        vim.fn.jobstart({ "go", "tool", "cover", "-o", lcov_out, coverprofile }, {
            on_exit = function(_, code)
                if code == 0 then
                    vim.schedule(function()
                        require("coverage").load(lcov_out, require("coverage.signs").is_enabled())
                    end)
                end
            end,
        })
    end
    return {}
end

return consumer
