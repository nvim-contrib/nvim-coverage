--- Generic neotest consumer that reloads coverage after every test run.
--- Suitable for any language where the lcov file is written during the test
--- run itself (e.g. Rust with cargo-llvm-cov).
---
--- Usage:
---   require("neotest").setup({
---     consumers = {
---       coverage = require("coverage.neotest"),
---     },
---   })
---
--- @type fun(client: table): table
local consumer = function(client)
    client.listeners.results = function(_, _, partial)
        if not partial then
            require("coverage").load(nil, require("coverage.signs").is_enabled())
        end
    end
    return {}
end

return consumer
