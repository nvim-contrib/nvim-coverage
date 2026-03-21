# VHS tapes

Requires [vhs](https://github.com/charmbracelet/vhs).

```
brew install vhs
```

## Usage

Run a single tape from the repo root:

```sh
vhs doc/tapes/signs.tape
vhs doc/tapes/report.tape
vhs doc/tapes/heatmap.tape
vhs doc/tapes/branch.tape   # produces a PNG screenshot
```

Output files are written to `doc/tapes/output/` (not committed).

## Before recording

1. Have a project open with an lcov file at one of the default paths
   (`lcov.info`, `coverage/lcov.info`, `target/lcov.info`, etc.)
2. Edit the `Type "nvim src/main.rs"` line in each tape to point at a real
   source file in your project that has interesting coverage data.
3. For `branch.tape`, make sure the file has at least one partial line (purple sign).

## Tapes

| File | Output | README placement |
|------|--------|-----------------|
| `signs.tape` | `output/signs.webp` | Below the feature list |
| `report.tape` | `output/report.webp` | After the Commands table |
| `heatmap.tape` | `output/heatmap.webp` | After `:CoverageHeatmap` row |
| `branch.tape` | `output/branch.png` | After the Summary popup keys table |
