vim.o.swapfile = false
vim.opt.rtp:append(".")

local function add_plugin(path)
    local expanded = vim.fn.expand(path)
    if vim.fn.isdirectory(expanded) == 1 then
        vim.opt.rtp:append(expanded)
    end
end

add_plugin("~/.local/share/nvim/lazy/plenary.nvim")

vim.cmd.runtime({ "plugin/plenary.vim", bang = true })
