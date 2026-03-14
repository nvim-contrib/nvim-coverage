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
	client.listeners.results["coverage.neotest.python"] = function(_, _, partial)
		if partial then
			return
		end

		vim.schedule(function()
			local cwd = vim.fn.getcwd()
			local coverage_db = cwd .. "/.coverage"
			local path = cwd .. "/coverage/lcov.info"

			if vim.fn.filereadable(coverage_db) ~= 1 then
				return
			end

			vim.fn.mkdir(cwd .. "/coverage", "p")
			vim.fn.jobstart({ "python", "-m", "coverage", "lcov", "-o", path }, {
				cwd = cwd,
				on_exit = function(_, code)
					if code == 0 then
						vim.schedule(function()
							require("coverage").load(path, true)
						end)
					end
				end,
			})
		end)
	end
	return {}
end

return consumer
