# GIF 3 — Full-screen heatmap treemap

Output tapes/output/heatmap.webp

Set Shell "zsh"
Set FontSize 14
Set Width 1280
Set Height 720
Set Theme "Catppuccin Mocha"
Set FontFamily "JetBrainsMono Nerd Font"
Set Framerate 30
Set PlaybackSpeed 0.75
Hide
Type "cd /Users/iamralch/Projects/github.com/tmux-contrib/tmux-pomodoro/crates/pomodoro && clear"
Enter
Sleep 500ms
Show

Type "nvim src/app/cmd.rs"
Enter
Sleep 3s

Type ":CoverageLoad"
Enter
Sleep 2s

Type ":CoverageHeatmap"
Enter
Sleep 1.5s

Type "l"
Sleep 300ms
Type "l"
Sleep 300ms
Type "j"
Sleep 300ms
Type "l"
Sleep 500ms

Type ""
Sleep 1.5s

Type ":qa!"
Enter
