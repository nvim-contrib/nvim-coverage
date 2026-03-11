# nvim-coverage

[![test](https://github.com/nvim-contrib/nvim-coverage/actions/workflows/test.yml/badge.svg)](https://github.com/nvim-contrib/nvim-coverage/actions/workflows/test.yml)
[![Release](https://img.shields.io/github/v/release/nvim-contrib/nvim-coverage?include_prereleases)](https://github.com/nvim-contrib/nvim-coverage/releases)
[![License](https://img.shields.io/github/license/nvim-contrib/nvim-coverage)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-blueviolet?logo=neovim&logoColor=white)](https://neovim.io)

A Neovim plugin that displays code coverage from [lcov](http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php) files directly in the editor — sign column markers, highlight groups, a summary popup, virtual text hit counts, branch overlays, and quickfix/loclist navigation.

> Built on the foundation of [andythigpen/nvim-coverage](https://github.com/andythigpen/nvim-coverage), stripped down and focused exclusively on lcov.

## Features

- Sign column markers for covered, uncovered, and partially covered lines
- Branch coverage support (partial signs) with per-branch overlay popup
- Virtual text showing execution hit counts per line
- Coverage summary popup with per-file stats, sortable by coverage
- Quickfix list (per-file summary) and location list (per-line) navigation
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
    require("coverage").setup()
  end,
}
```

### packer.nvim

```lua
use({
  "nvim-contrib/nvim-coverage",
  requires = "nvim-lua/plenary.nvim",
  config = function()
    require("coverage").setup()
  end,
})
```

## Generating lcov files

The plugin reads a pre-generated lcov file — it does not run tests or invoke any tools itself.

By default the plugin searches for an lcov file in these locations (first existing file wins):

```
lcov.info
cover/lcov.info
coverage/lcov.info
target/lcov.info
```

Override with the `file` option if your tool writes elsewhere.

| Language | Command | Default output path |
|----------|---------|---------------------|
| Go | `go test -coverprofile=coverage.out ./... && go tool cover -o coverage/lcov.info coverage.out` | `coverage/lcov.info` |
| Rust | `cargo +nightly llvm-cov --lcov --branch --output-path target/lcov.info` | `target/lcov.info` |
| JavaScript/TypeScript | `jest --coverage` | `coverage/lcov.info` |
| Python | `pytest --cov && coverage lcov -o coverage/lcov.info` | `coverage/lcov.info` |
| C/C++ | `lcov --capture --directory . --output-file lcov.info` | `lcov.info` |
| Swift | `xcrun xccov view --report --json ... \| <converter>` | `coverage/lcov.info` |

## Configuration

```lua
require("coverage").setup({
  -- path (or list of paths) to the lcov file; first existing file wins
  -- defaults to: { "lcov.info", "cover/lcov.info", "coverage/lcov.info", "target/lcov.info" }
  -- file = "coverage/lcov.info",

  -- register :Coverage* commands (default: true)
  commands = true,

  auto_reload = {
    enabled = false,    -- auto-reload signs when lcov file changes on disk
    timeout_ms = 500,   -- debounce delay before reloading
  },

  -- called after coverage is loaded
  on_load = nil,

  signs = {
    covered  = { hl = "CoverageCovered",   text = "▎" },
    uncovered = { hl = "CoverageUncovered", text = "▎" },
    partial  = { hl = "CoveragePartial",   text = "▎" },
  },

  highlights = {
    covered             = { fg = "#B7F071" },
    uncovered           = { fg = "#F07178" },
    partial             = { fg = "#AA71F0" },
    summary_border      = { link = "FloatBorder" },
    summary_normal      = { link = "NormalFloat" },
    summary_cursor_line = { link = "CursorLine" },
    summary_header      = { style = "bold,underline", sp = "fg" },
    summary_pass        = { link = "CoverageCovered" },
    summary_fail        = { link = "CoverageUncovered" },
    virtual_text        = { link = "Comment" },
  },

  summary = {
    width        = 0.70,
    height       = 0.50,
    min_coverage = 80.0, -- threshold for pass/fail highlight in summary
  },

  virtual_text = {
    enabled  = false,           -- show hit counts automatically after load
    position = "eol",           -- "eol" | "right_align" | "inline"
  },
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:CoverageLoad [file]` | Load lcov file and place signs (uses `file` config if no arg) |
| `:CoverageShow` | Show signs (if previously hidden) |
| `:CoverageHide` | Hide signs |
| `:CoverageToggle` | Toggle sign visibility |
| `:CoverageClear` | Remove signs, clear cache, stop file watcher |
| `:CoverageSummary` | Open the summary popup |
| `:CoverageToggleLineHits` | Toggle virtual text hit counts per line |
| `:CoverageToggleBranchHits` | Toggle branch overlay popup on partial lines |
| `:CoverageQuickfix [uncovered]` | Populate quickfix list with per-file coverage summary |
| `:CoverageLoclist [uncovered\|partial]` | Populate location list with lines of given type in current buffer |

### Lua API

```lua
local coverage = require("coverage")

-- load
coverage.load()                          -- load from config.file
coverage.load("path/to/lcov.info")       -- load from explicit path
coverage.load("path/to/lcov.info", true) -- load and immediately show signs

-- signs
coverage.show()
coverage.hide()
coverage.toggle()
coverage.clear()

-- summary popup
coverage.summary()

-- virtual text — shows execution hit counts (e.g. × 42) on every instrumented line
coverage.toggle_line_hits()

-- branch overlay — floating popup on partial lines showing per-branch counts
coverage.toggle_branch_hits()

-- quickfix / loclist navigation
coverage.quickfix()             -- all files, sorted by coverage ascending
coverage.quickfix("uncovered")  -- only files with uncovered lines
coverage.loclist()              -- uncovered lines in current buffer
coverage.loclist("partial")     -- partially covered lines in current buffer

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

### Quickfix / loclist workflow

```
:CoverageQuickfix uncovered   → quickfix list of files with gaps, worst first
:CoverageLoclist              → location list of uncovered lines in current file
:CoverageLoclist partial      → location list of partially covered lines
```

Navigate the quickfix list with `:cnext` / `:cprev` (or `]q` / `[q` with a mapping).
Navigate the location list with `:lnext` / `:lprev`.

### Auto-reload with neotest

If you use [neotest](https://github.com/nvim-neotest/neotest), hook into test results to reload coverage automatically after every run:

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
