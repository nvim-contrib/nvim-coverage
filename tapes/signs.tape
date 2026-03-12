# GIF — Sign column + virtual text

Output tapes/output/signs.webp

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

# Redefine signs with a thicker block char before loading coverage
Type ":luafile /Users/iamralch/Projects/github.com/nvim-contrib/nvim-coverage/tapes/sign_override.lua"
Enter
Sleep 500ms

Type ":CoverageLoad"
Enter
Sleep 3s

# Navigate to show mix of covered and uncovered lines
Type ":50"
Enter
Sleep 1s

Type "20k"
Sleep 1.5s

Type "25j"
Sleep 1s

Type ":CoverageToggleLineHits"
Enter
Sleep 1.5s

Type "10k"
Sleep 500ms
Type "5j"
Sleep 1s

Type ":qa!"
Enter
