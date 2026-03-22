# GIF 3 — Full-screen heatmap treemap

Output doc/tapes/output/heatmap.webp

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
Type "cd doc/tapes/demo && clear"
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
