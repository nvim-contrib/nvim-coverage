--- Go neotest consumer that converts coverage.out to lcov after tests finish,
--- then reloads coverage.
---
--- Expects tests to be run with `-coverprofile=coverage.out` (e.g. via ginkgo
--- or neotest-go/neotest-golang with coverage flags enabled).
---
--- After tests finish the consumer globs for all `**/coverage.out` files under
--- cwd, converts each to lcov in pure Lua, concatenates the results
--- into `cwd/coverage/lcov.info`, and loads the merged file.
---
--- Usage:
---   require("neotest").setup({
---     consumers = {
---       coverage_go = require("coverage.neotest.go"),
---     },
---   })

local go_cov = require("coverage.neotest.go_cov")

--- Finds the coverage.out file in the neotest results output directories.
--- @param results table<string, neotest.Result> neotest results
--- @return string|nil path to coverage.out if found
local function find_coverage_profile(results)
	if not results then
		return nil
	end
	for _, result in pairs(results) do
		if result.output then
			local path = vim.fn.fnamemodify(result.output, ":h") .. "/coverage.out"
			if vim.fn.filereadable(path) == 1 then
				return path
			end
		end
	end
	return nil
end

local consumer = function(client)
	client.listeners.results = function(_, results, partial)
		if partial then
			return
		end

		vim.schedule(function()
			local path = find_coverage_profile(results)
			if not path then
				return
			end

			local report = go_cov.to_lcov({ path })
			if #report == 0 then
				return
			end

			local lcov_out = vim.fn.getcwd() .. "/lcov.info"
			vim.fn.writefile(report, lcov_out)
			require("coverage").load(lcov_out, true)
		end)
	end
	return {}
end

return consumer
