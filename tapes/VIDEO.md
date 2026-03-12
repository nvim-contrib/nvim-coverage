# Recording guide for README assets

## Recommended recordings

### 1. GIF — Sign column + virtual text (the core feature)

**What to show:**
1. Open a source file with no signs
2. `:CoverageLoad` → signs appear in the gutter (green/red/purple bars)
3. `:CoverageToggleLineHits` → `× 42` virtual text appears on each line

**Why:** This is the first feature listed and the most common use case. Short, punchy, goes right below the feature list.

---

### 2. GIF — Coverage report popup

**What to show:**
1. `:CoverageReport` → popup opens, centered table with per-file stats
2. Press `s` / `S` to re-sort by coverage
3. `<CR>` on a file → jumps to it, signs visible

**Why:** Demonstrates the interactive UI. Replaces the current text-only description.

---

### 3. GIF — Heatmap

**What to show:**
1. `:CoverageHeatmap` → full-screen treemap fills terminal
2. Move cursor around a few blocks
3. `<CR>` to jump to a file, `q` to close

**Why:** Most visually distinctive feature — worth its own clip.

---

### 4. Screenshot — Branch overlay

**What to show:**
- Cursor on a partial (purple) line with the branch popup open showing per-branch hit counts

**Why:** Static screenshot is enough — it's a floating popup, not interactive.

---

## Recording setup

**Before recording:**
- Use a project with meaningful coverage gaps (Rust or Go works well — `target/lcov.info` from the repo itself)
- Increase font size (18–20pt) so text is readable at GIF width (~800px)
- Use a clean tmux/terminal with no distracting chrome
- Set terminal width to ~120 cols so the heatmap and report look good

**Recommended tools:**
- [vhs](https://github.com/charmbracelet/vhs) — scriptable, produces clean GIFs, easy to re-record when UI changes
- [asciinema](https://asciinema.org/) + [agg](https://github.com/asciinema/agg) — alternative for converting to GIF

vhs is preferred: write a `.tape` file once and re-run it any time the UI changes.

---

## Placement in README

| Section | Asset |
|---------|-------|
| Top, just below the badge row | GIF #1 (signs + virtual text) |
| After the Commands table | GIF #2 (report popup) |
| After `:CoverageHeatmap` command row | GIF #3 (heatmap) |
| After the Summary popup keys table | Screenshot #4 (branch overlay) |
