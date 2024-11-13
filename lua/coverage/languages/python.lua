local M = {}

local Path = require("plenary.path")
local common = require("coverage.languages.common")
local config = require("coverage.config")
local util = require("coverage.util")

local is_pipenv = function()
	return vim.fn.filereadable("Pipfile") ~= 0
end

--- Returns a list of signs to be placed.
M.sign_list = common.sign_list

--- Returns a summary report.
M.summary = common.summary

M.buffer_is_valid = function(buf_id, buf_name)
	return 1 == vim.fn.buflisted(buf_id) and buf_name ~= ""
end

--- Loads a coverage report.
-- @param callback called with the results of the coverage report
M.load = function(callback)
	local python_config = config.opts.lang.python
	local p = Path:new(util.get_coverage_file(python_config.coverage_file))
	if not p:exists() then
		vim.notify("No coverage data file exists.", vim.log.levels.INFO)
		return
	end

	local cmd = python_config.coverage_command
	cmd = cmd .. " --data-file=" .. tostring(p)
	if python_config.only_open_buffers then
		local includes = {}
		local buffers = vim.api.nvim_list_bufs()
		for idx = 1, #buffers do
			local buf_id = buffers[idx]
			local buf_name = vim.api.nvim_buf_get_name(buf_id)
			-- if buffer is listed, then add to the includes list
			if M.buffer_is_valid(buf_id, buf_name) then
				table.insert(includes, buf_name)
			end
		end
		if next(includes) ~= nil then
			cmd = cmd .. " --include=" .. table.concat(includes, ",")
		end
	end
	if is_pipenv() then
		cmd = "pipenv run " .. cmd
	end

	local stdout = ""
	local stderr = ""
	vim.fn.jobstart(cmd, {
		on_stdout = vim.schedule_wrap(function(_, data, _)
			for _, line in ipairs(data) do
				stdout = stdout .. line
			end
		end),
		on_stderr = vim.schedule_wrap(function(_, data, _)
			for _, line in ipairs(data) do
				stderr = stderr .. line
			end
		end),
		on_exit = vim.schedule_wrap(function(_, exit_code)
			if exit_code ~= 0 then
				if #stderr == 0 then
					stderr = "Failed to generate coverage"
				end
				vim.notify(stderr, vim.log.levels.ERROR)
				return
			elseif #stderr > 0 then
				vim.notify(stderr, vim.log.levels.WARN)
			end
			if stdout == "No data to report." then
				vim.notify(stdout, vim.log.levels.INFO)
				return
			end
			util.safe_decode(stdout, callback)
		end),
	})
end

return M
