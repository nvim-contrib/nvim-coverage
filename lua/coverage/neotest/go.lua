--- Go neotest consumer that converts coverage.out to lcov after tests finish,
--- then reloads coverage.
---
--- Searches neotest output directories for `coverage.out` files generated
--- during the test run. Merges all profiles found into a single lcov report
--- and loads it.
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
	--- @param results table<string, neotest.Result>
	--- @return string[] deduplicated list of coverage.out paths
	local function find_in_results(results)
		if not results then
			return {}
		end
		local seen = {}
		local found = {}
		for _, result in pairs(results) do
			if result.output then
				local dir = vim.fn.fnamemodify(result.output, ":h")
				local path = dir .. "/coverage.out"
				if not seen[path] and vim.fn.filereadable(path) == 1 then
					seen[path] = true
					found[#found + 1] = path
				end
			end
		end
		return found
	end

	client.listeners.results = function(_, results, partial)
		if partial then
			return
		end

		vim.schedule(function()
			local paths = find_in_results(results)
			if #paths == 0 then
				return
			end

			local report = require("coverage.neotest.go_cov").to_lcov(paths)
			if #report == 0 then
				return
			end

			local report_path = vim.fn.tempname() .. ".info"
			vim.fn.writefile(report, report_path)
			require("coverage").load(report_path, { place = true, silent = true })
		end)
	end

	return {}
end

return consumer
