# GIF 2 — Coverage report popup

Output tapes/output/report.webp

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

Type ":CoverageReport"
Enter
Sleep 1s

Type "S"
Sleep 1s

Type "s"
Sleep 1s

Type "3j"
Sleep 500ms

Type ""
Sleep 1.5s

Type ":qa!"
Enter
