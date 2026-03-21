# Screenshot — Branch overlay popup on a partial line

Output doc/tapes/output/branch.png

Set Shell "zsh"
Set FontSize 18
Set Width 1200
Set Height 700
Set Theme "Catppuccin Mocha"
Set FontFamily "JetBrainsMono Nerd Font"
Set CursorBlink false
Set Padding 20
Hide
Type "cd doc/demo && clear"
Enter
Sleep 500ms
Show

Type "nvim src/hook/run.rs"
Enter
Sleep 3s

Type ":CoverageLoad"
Enter
Sleep 2s

Type ":CoverageLoclist partial"
Enter
Sleep 1s

Type ":lnext"
Enter
Sleep 500ms

Type ":CoverageToggleBranchHints"
Enter
Sleep 1.5s

Screenshot doc/tapes/output/branch.png
