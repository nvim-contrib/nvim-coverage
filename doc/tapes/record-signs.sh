#!/usr/bin/env zsh
set -e

PROJECT="/Users/iamralch/Projects/github.com/tmux-contrib/tmux-pomodoro/crates/pomodoro"
SESSION="nvim-coverage-signs"
CAST="doc/tapes/output/signs.cast"
GIF="doc/tapes/output/signs.gif"

mkdir -p doc/tapes/output

# Kill existing session if any
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Start a detached tmux session sized to match the recording dimensions
tmux new-session -d -s "$SESSION" -x 220 -y 50

# Start asciinema recording in background (attaches to the tmux session)
asciinema rec "$CAST" --overwrite --command "tmux attach-session -t $SESSION" &
ASCIINEMA_PID=$!
sleep 1.5

send() { tmux send-keys -t "$SESSION" "$1" "${2:-Enter}"; }
pause() { sleep "$1"; }

send "cd $PROJECT && clear"
pause 0.5

send "nvim src/app/cmd.rs"
pause 4

# Load coverage
send ":CoverageLoad"
pause 3

# Jump to line 50 — mix of covered and uncovered lines nearby
send ":50"
pause 1

# Scroll up through covered lines (green signs)
send "20k" ""
pause 1.5

# Scroll back down through uncovered lines (red signs at 84-90)
send "25j" ""
pause 1

# Toggle virtual text hit counts
send ":CoverageToggleLineHits"
pause 2

send "10k" ""
pause 0.5
send "5j" ""
pause 1

send ":qa!"
pause 1

# Wait for asciinema to finish
wait $ASCIINEMA_PID

echo "Converting to GIF..."
agg "$CAST" "$GIF" \
  --font-family "JetBrainsMono Nerd Font" \
  --font-size 16 \
  --speed 1.5

echo "Done: $GIF"
