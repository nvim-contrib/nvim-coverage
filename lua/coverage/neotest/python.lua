--- Python neotest consumer that converts .coverage to lcov after tests finish,
--- then reloads coverage. Requires `coverage` (coverage.py) to be available.
---
--- Expects tests to be run with coverage enabled (e.g. via pytest-cov or
--- neotest-python with coverage flags, and `[tool.pytest.ini_options]
--- addopts = "--cov"` in pyproject.toml).
---
--- Usage:
---   require("neotest").setup({
---     consumers = {
---       coverage_python = require("coverage.neotest.python"),
---     },
---   })
---
--- @type fun(client: table): table
local consumer = function(client)
    client.listeners.results = function(_, _, partial)
        if partial then return end

        vim.schedule(function()
            local cwd      = vim.fn.getcwd()
            local db       = cwd .. "/.coverage"
            local lcov_out = cwd .. "/coverage/lcov.info"

            if vim.fn.filereadable(db) ~= 1 then return end

            vim.fn.mkdir(cwd .. "/coverage", "p")
            vim.fn.jobstart({ "python", "-m", "coverage", "lcov", "-o", lcov_out }, {
                cwd = cwd,
                on_exit = function(_, code)
                    if code == 0 then
                        vim.schedule(function()
                            require("coverage").load(lcov_out, true)
                        end)
                    end
                end,
            })
        end)
    end
    return {}
end

return consumer
