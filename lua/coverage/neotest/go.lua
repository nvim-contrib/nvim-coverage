--- Go neotest consumer that converts coverage.out to lcov after tests finish,
--- then reloads coverage.
---
--- Expects tests to be run with `-coverprofile=coverage.out` (e.g. via ginkgo
--- or neotest-go/neotest-golang with coverage flags enabled).
---
--- After tests finish the consumer converts `cwd/coverage.out` to lcov,
--- writes `cwd/lcov.info` alongside it, and loads the result.
---
--- Usage:
---   require("neotest").setup({
---     consumers = {
---       coverage_go = require("coverage.neotest.go"),
---     },
---   })

--- Converts a Go coverage.out file to lcov format.
--- @param path string path to coverage.out
--- @return string[] lcov lines
local gcov_to_lcov = function(path)
    -- file_path -> { line_number -> count }
    local file_data = {}

    do
        local lines = vim.fn.readfile(path)
        for _, line in ipairs(lines) do
            if line:match("^mode:") then
                goto continue
            end

            local file, startline, endline, count =
                line:match("^(.+):(%d+)%.%d+,(%d+)%.%d+%s+%d+%s+(%d+)$")
            if not file then
                goto continue
            end

            startline = tonumber(startline)
            endline = tonumber(endline)
            count = tonumber(count)

            if not file_data[file] then
                file_data[file] = {}
            end
            local lines_map = file_data[file]

            for l = startline, endline do
                lines_map[l] = (lines_map[l] or 0) + count
            end

            ::continue::
        end
    end -- do

    local result = {}
    -- Sort files for deterministic output.
    local sorted_files = vim.tbl_keys(file_data)
    table.sort(sorted_files)

    for _, file in ipairs(sorted_files) do
        local lines_map = file_data[file]
        local sorted_lines = vim.tbl_keys(lines_map)
        table.sort(sorted_lines)

        local lf = #sorted_lines
        local lh = 0
        local da_records = {}

        for _, l in ipairs(sorted_lines) do
            local c = lines_map[l]
            da_records[#da_records + 1] = "DA:" .. l .. "," .. c
            if c > 0 then
                lh = lh + 1
            end
        end

        result[#result + 1] = "SF:" .. file
        for _, da in ipairs(da_records) do
            result[#result + 1] = da
        end
        result[#result + 1] = "LF:" .. lf
        result[#result + 1] = "LH:" .. lh
        result[#result + 1] = "end_of_record"
    end

    return result
end

--- @type table
local M = {
    _gcov_to_lcov = gcov_to_lcov,
}

setmetatable(M, {
    __call = function(_, client)
        client.listeners.results = function(_, _, partial)
            if partial then return end

            vim.schedule(function()
                local cwd = vim.fn.getcwd()
                local profile = cwd .. "/coverage.out"
                if vim.fn.filereadable(profile) ~= 1 then return end

                local lcov_out = cwd .. "/lcov.info"
                local lcov = gcov_to_lcov(profile)
                if #lcov == 0 then return end

                vim.fn.writefile(lcov, lcov_out)
                require("coverage").load(lcov_out, true)
            end)
        end
        return {}
    end,
})

return M
