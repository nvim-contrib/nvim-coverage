# nvim-coverage

[![License](https://img.shields.io/github/license/nvim-contrib/nvim-coverage)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-blueviolet?logo=neovim&logoColor=white)](https://neovim.io)

A Neovim plugin that displays code coverage from [lcov](http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php) files directly in the editor — sign column markers, highlight groups, and a summary popup.

> Built on the foundation of [andythigpen/nvim-coverage](https://github.com/andythigpen/nvim-coverage), stripped down and focused exclusively on lcov.

## Features

- Sign column markers for covered, uncovered, and partially covered lines
- Branch coverage support (partial signs)
- Coverage summary popup with per-file stats, sortable by coverage
- Auto-reload when the lcov file changes on disk
- Works with any language that produces lcov output

## Requirements

- Neovim >= 0.9
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation

### lazy.nvim

```lua
{
  "nvim-contrib/nvim-coverage",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("coverage").setup({
      lcov_file = "coverage/lcov.info",
    })
  end,
}
```

### packer.nvim

```lua
use({
  "nvim-contrib/nvim-coverage",
  requires = "nvim-lua/plenary.nvim",
  config = function()
    require("coverage").setup({
      lcov_file = "coverage/lcov.info",
    })
  end,
})
```

## Generating lcov files

The plugin reads a pre-generated lcov file — it does not run tests or invoke any tools itself.

| Language       | Command |
|----------------|---------|
| Go             | `go test -coverprofile=coverage.out ./... && go tool cover -o coverage/lcov.info coverage.out` |
| Rust           | `cargo llvm-cov --lcov --output-path coverage/lcov.info` |
| JavaScript/TypeScript | Jest: `jest --coverage` (outputs `coverage/lcov.info` by default) |
| Python         | `pytest --cov && coverage lcov -o coverage/lcov.info` |
| C/C++          | `lcov --capture --directory . --output-file coverage/lcov.info` |
| Swift          | `xcrun xccov view --report --json ... | <converter>` |

## Configuration

```lua
require("coverage").setup({
  -- path to the lcov file (required)
  lcov_file = "coverage/lcov.info",

  -- register :Coverage* commands (default: true)
  commands = true,

  -- auto-reload signs when the lcov file changes on disk (default: false)
  auto_reload = false,
  auto_reload_timeout_ms = 500,

  -- called after coverage is loaded, receives "lcov" as argument
  load_coverage_cb = nil,

  signs = {
    covered  = { hl = "CoverageCovered",   text = "▎" },
    uncovered = { hl = "CoverageUncovered", text = "▎" },
    partial  = { hl = "CoveragePartial",   text = "▎" },
  },

  highlights = {
    covered        = { fg = "#B7F071" },
    uncovered      = { fg = "#F07178" },
    partial        = { fg = "#AA71F0" },
    summary_border      = { link = "FloatBorder" },
    summary_normal      = { link = "NormalFloat" },
    summary_cursor_line = { link = "CursorLine" },
    summary_header      = { style = "bold,underline", sp = "fg" },
    summary_pass        = { link = "CoverageCovered" },
    summary_fail        = { link = "CoverageUncovered" },
  },

  summary = {
    width_percentage  = 0.70,
    height_percentage = 0.50,
    min_coverage      = 80.0, -- threshold for pass/fail highlight in summary
  },
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:CoverageLoad [file]` | Load lcov file and place signs (uses `lcov_file` if no arg) |
| `:CoverageShow` | Show signs (if previously hidden) |
| `:CoverageHide` | Hide signs |
| `:CoverageToggle` | Toggle sign visibility |
| `:CoverageClear` | Remove signs and clear cache |
| `:CoverageSummary` | Open the summary popup |

### Lua API

```lua
local coverage = require("coverage")

coverage.load()                        -- load from config.lcov_file
coverage.load("path/to/lcov.info")     -- load from explicit path
coverage.load("path/to/lcov.info", true) -- load and immediately show signs

coverage.show()
coverage.hide()
coverage.toggle()
coverage.clear()
coverage.summary()

-- jump to next/previous sign
coverage.jump_next("uncovered")  -- "covered" | "uncovered" | "partial"
coverage.jump_prev("uncovered")
```

### Summary popup keys

| Key | Action |
|-----|--------|
| `s` | Sort by coverage ascending |
| `S` | Sort by coverage descending |
| `H` | Jump to top entry |
| `<CR>` | Open file under cursor |
| `?` | Toggle help |
| `q` / `<Esc>` | Close |

### Auto-reload with neotest

If you use [neotest](https://github.com/nvim-neotest/neotest), you can hook into test results to reload coverage automatically:

```lua
require("neotest").setup({
  consumers = {
    coverage = function(client)
      client.listeners.results = function(_, _, partial)
        if not partial then
          require("coverage").load(nil, require("coverage.signs").is_enabled())
        end
      end
      return {}
    end,
  },
})
```

## Contributing

Contributions are welcome. Please open an issue or pull request.

## License

[MIT](LICENSE)
