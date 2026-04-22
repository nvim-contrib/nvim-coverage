--- Go neotest consumer that converts coverage.out to lcov after tests finish,
--- then reloads coverage.
---
--- Expects tests to be run with `-coverprofile=coverage.out` (e.g. via ginkgo
--- or neotest-go/neotest-golang with coverage flags enabled).
---
--- After tests finish the consumer finds `coverage.out` in the neotest output
--- directory, converts it to lcov in pure Lua, writes the result to
--- `cwd/lcov.info`, and loads the merged file.
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
			local report_dir = vim.fn.fnamemodify(result.output, ":h")
			local report_path = report_dir .. "/coverage.out"
			if vim.fn.filereadable(report_path) == 1 then
				return report_path
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

			local report_dir = vim.fn.fnamemodify(path, ":h")
			local report_path = report_dir .. "/lcov.info"
			vim.fn.writefile(report, report_path)
			require("coverage").load(report_path, true)
		end)
	end
	return {}
end

return consumer
