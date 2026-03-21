# GIF — Sign column + virtual text

Output doc/tapes/output/signs.webp

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
Type "export REPO=$(pwd) && cd doc/demo && clear"
Enter
Sleep 500ms
Type "nvim src/app/cmd.rs"
Enter
Sleep 3s
# Reconfigure signs with a thicker block char before loading coverage
Type ":luafile $REPO/doc/tapes/sign_override.lua"
Enter
Sleep 500ms
Type ":CoverageLoad"
Enter
Sleep 3s
Type ":CoverageShowLineSigns"
Enter
Sleep 1s
Show

# Navigate to show mix of covered and uncovered lines
Type ":50"
Enter
Sleep 1s

Type "20k"
Sleep 1.5s

Type "25j"
Sleep 1s

Type ":CoverageToggleLineHints"
Enter
Sleep 1.5s

Type "10k"
Sleep 500ms
Type "5j"
Sleep 1s

Type ":qa!"
Enter
