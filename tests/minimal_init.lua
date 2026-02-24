-- Minimal init file for running tests via headless Neovim + plenary.nvim

-- Add project lua path
local project_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(project_root)

-- Locate plenary (required for test runner)
local plenary_path = vim.fn.expand("~/.local/share/nvim/site/pack/vendor/start/plenary.nvim")
if vim.fn.isdirectory(plenary_path) == 0 then
    -- Try common plugin manager paths
    local fallbacks = {
        vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim"),
        vim.fn.expand("~/.vim/plugged/plenary.nvim"),
    }
    for _, p in ipairs(fallbacks) do
        if vim.fn.isdirectory(p) == 1 then
            plenary_path = p
            break
        end
    end
end
vim.opt.rtp:prepend(plenary_path)

-- Stub out vim.notify to avoid UI errors during tests
vim.notify = function(msg, level)
    -- silent during tests; uncomment for debug:
    -- print("[notify] " .. tostring(level) .. ": " .. tostring(msg))
end
