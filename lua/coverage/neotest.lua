--- Optional neotest consumer that auto-loads coverage after a test run.
---
--- Enable it in your config:
---
---   require("coverage").setup({
---     neotest = { enabled = true },
---   })
---
--- Then register the consumer with neotest:
---
---   require("neotest").setup({
---     consumers = {
---       coverage = require("coverage.neotest"),
---     },
---   })
---
--- After every neotest run that completes (pass or fail), coverage will reload
--- automatically for the filetype of the currently focused buffer.

local M = {}

--- Called by neotest with the neotest client instance.
--- Must return a table with at least a `name` field.
--- @param client table neotest client
--- @return table consumer
M = function(client)
    client.listeners.results = function(adapter_id, results, partial)
        if partial then
            -- Don't reload on intermediate (streaming) results
            return
        end

        local config = require("coverage.config")
        if not config.opts.neotest or not config.opts.neotest.enabled then
            return
        end

        -- Reload coverage for the current buffer's filetype
        vim.schedule(function()
            require("coverage").load(require("coverage.signs").is_enabled())
        end)
    end

    return {}
end

return M
