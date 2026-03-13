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

local consumer = function(client)
	client.listeners.results = function(_, _, partial)
		if partial then
			return
		end

		vim.schedule(function()
			local cwd = vim.fn.getcwd()
			local path = cwd .. "/coverage.out"

			if vim.fn.filereadable(path) == 0 then
				local fcwd = vim.fn.expand("%:p:h")
				local fpath = fcwd .. "/coverage.out"
				vim.fn.system({ "mv", "-f", fpath, path })
			end

			if vim.fn.filereadable(path) == 0 then
				return
			end

			local report = go_cov.to_lcov({ path })
			if #report == 0 then
				return
			end

			local lcov_out = cwd .. "/lcov.info"
			vim.fn.writefile(report, lcov_out)
			require("coverage").load(lcov_out, true)
		end)
	end
	return {}
end

return consumer
