# GIF 2 — Coverage report popup

Output doc/tapes/output/report.webp

Set Shell "zsh"
Set FontSize 18
Set Width 1200
Set Height 700
Set Theme "Catppuccin Mocha"
Set FontFamily "JetBrainsMono Nerd Font"
Set Framerate 15
Set CursorBlink false
Set Padding 20
Set TypingSpeed 75ms
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
