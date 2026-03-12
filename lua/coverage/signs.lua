local M = {}
local config = require("coverage.config")

local prefix = "coverage_"
local enabled = false
local cached_signs = nil
local default_priority = 10

--- @class Sign
--- @field hl string name of the highlight group
--- @field text string text to place in sign column
--- @field priority integer? optional priority (default 10; highest wins)

--- @class SignPlace
--- @field buffer string|integer
--- @field group string
--- @field id? integer
--- @field lnum integer
--- @field name string
--- @field priority integer

local name = function(n)
	return prefix .. n
end

--- Defines signs.
M.setup = function()
	vim.fn.sign_define(
		name("covered"),
		{ text = config.opts.signs.covered.text, texthl = config.opts.signs.covered.hl }
	)
	vim.fn.sign_define(
		name("uncovered"),
		{ text = config.opts.signs.uncovered.text, texthl = config.opts.signs.uncovered.hl }
	)
	vim.fn.sign_define(
		name("partial"),
		{ text = config.opts.signs.partial.text, texthl = config.opts.signs.partial.hl }
	)
end

--- Caches signs but does not place them.
--- @param signs SignPlace[]
M.cache = function(signs)
	M.unplace()
	cached_signs = signs
end

--- Places a list of signs, removing any previously placed signs.
--- @param signs SignPlace[]
M.place = function(signs)
	if cached_signs ~= nil then
		M.unplace()
	end
	vim.fn.sign_placelist(signs)
	enabled = true
	cached_signs = signs
end

--- Unplaces all coverage signs.
M.unplace = function()
	vim.fn.sign_unplace(config.opts.sign_group)
	enabled = false
end

--- Returns true if coverage signs are currently shown.
M.is_enabled = function()
	return enabled
end

--- Displays cached signs.
M.show = function()
	if enabled or cached_signs == nil then
		return
	end
	M.place(cached_signs)
end

--- Toggles the visibility of coverage signs.
M.toggle = function()
	if enabled then
		M.unplace()
	elseif cached_signs ~= nil then
		M.place(cached_signs)
	end
end

--- Turns off coverage signs and removes cached results.
M.clear = function()
	M.unplace()
	cached_signs = nil
end

--- Jumps to a sign of the given type in the given direction.
--- @param sign_type? "covered"|"uncovered"|"partial" Defaults to "covered"
--- @param direction? -1|1 Defaults to 1 (forward)
M.jump = function(sign_type, direction)
	if not enabled or cached_signs == nil then
		return
	end
	local placed = vim.fn.sign_getplaced("", { group = config.opts.sign_group })
	if #placed == 0 then
		return
	end

	local current_lnum = vim.fn.line(".")
	local sign_name = name(sign_type or "covered")
	direction = direction or 1

	local placed_signs = placed[1].signs
	if direction < 0 then
		table.sort(placed_signs, function(a, b)
			return a.lnum > b.lnum
		end)
	end

	for _, sign in ipairs(placed_signs) do
		if direction > 0 and sign.lnum > current_lnum and sign_name == sign.name then
			vim.fn.sign_jump(sign.id, config.opts.sign_group, "")
			return
		elseif direction < 0 and sign.lnum < current_lnum and sign_name == sign.name then
			vim.fn.sign_jump(sign.id, config.opts.sign_group, "")
			return
		end
	end
end

--- @param buffer string|integer
--- @param lnum integer
--- @return SignPlace
M.new_covered = function(buffer, lnum)
	return {
		buffer = buffer,
		group = config.opts.sign_group,
		lnum = lnum,
		name = name("covered"),
		priority = config.opts.signs.covered.priority or default_priority,
	}
end

--- @param buffer string|integer
--- @param lnum integer
--- @return SignPlace
M.new_uncovered = function(buffer, lnum)
	return {
		buffer = buffer,
		group = config.opts.sign_group,
		lnum = lnum,
		name = name("uncovered"),
		priority = config.opts.signs.uncovered.priority or default_priority,
	}
end

--- @param buffer string|integer
--- @param lnum integer
--- @return SignPlace
M.new_partial = function(buffer, lnum)
	local priority = config.opts.signs.partial.priority
	if priority == nil then
		priority = (config.opts.signs.uncovered.priority or default_priority) + 1
	end
	return {
		buffer = buffer,
		group = config.opts.sign_group,
		lnum = lnum,
		name = name("partial"),
		priority = priority,
	}
end

--- Builds a list of SignPlace entries from a CoverageData table.
--- @param data CoverageData
--- @return SignPlace[]
M.build = function(data)
	local list = {}
	for fname, cov in pairs(data.files) do
		local buffer = vim.fn.bufnr(fname, false)
		if buffer ~= -1 then
			local partial_lnums = {}
			if cov.partial_lines ~= nil then
				for _, branch in ipairs(cov.partial_lines) do
					table.insert(partial_lnums, branch[1])
				end
			end

			for _, lnum in ipairs(cov.covered_lines) do
				if not vim.tbl_contains(partial_lnums, lnum) then
					table.insert(list, M.new_covered(buffer, lnum))
				end
			end

			for _, lnum in ipairs(cov.uncovered_lines) do
				table.insert(list, M.new_uncovered(buffer, lnum))
			end

			for _, lnum in ipairs(partial_lnums) do
				if not vim.tbl_contains(cov.uncovered_lines, lnum) then
					table.insert(list, M.new_partial(buffer, lnum))
				end
			end
		end
	end
	return list
end

return M
