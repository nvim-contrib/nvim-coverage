local M = {}

--- Reads the module path from go.mod in the given directory.
--- @param dir string directory containing go.mod
--- @return string|nil module path
local function read_module_path(dir)
    local gomod = dir .. "/go.mod"
    if vim.fn.filereadable(gomod) == 0 then
        return nil
    end
    for _, line in ipairs(vim.fn.readfile(gomod)) do
        local mod = line:match("^module%s+(%S+)")
        if mod then
            return mod
        end
    end
    return nil
end

--- Converts a list of Go coverage.out file paths to lcov format.
--- @param profiles string[] list of coverage.out file paths
--- @param dir? string project root (defaults to cwd), used to resolve module paths
--- @return string[] lcov lines
M.to_lcov = function(profiles, dir)
    dir = dir or vim.fn.getcwd()
    local mod_path = read_module_path(dir)

    -- file_path -> { line_number -> count }
    local file_data = {}

    for _, profile in ipairs(profiles) do
        local lines = vim.fn.readfile(profile)
        for _, line in ipairs(lines) do
            if line:match("^mode:") then
                goto continue
            end

            local file, startline, endline, count = line:match("^(.+):(%d+)%.%d+,(%d+)%.%d+%s+%d+%s+(%d+)$")
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
    end

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

        local sf = file
        if mod_path and file:sub(1, #mod_path) == mod_path then
            sf = dir .. file:sub(#mod_path + 1)
        end
        result[#result + 1] = "SF:" .. sf
        for _, da in ipairs(da_records) do
            result[#result + 1] = da
        end
        result[#result + 1] = "LF:" .. lf
        result[#result + 1] = "LH:" .. lh
        result[#result + 1] = "end_of_record"
    end

    return result
end

return M
