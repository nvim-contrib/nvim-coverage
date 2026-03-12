# Screenshot — Branch overlay popup on a partial line

Output tapes/output/branch.png

Set Shell "zsh"
Set FontSize 14
Set Width 1280
Set Height 720
Set Theme "Catppuccin Mocha"
Set FontFamily "JetBrainsMono Nerd Font"
Hide
Type "cd /Users/iamralch/Projects/github.com/tmux-contrib/tmux-pomodoro/crates/pomodoro && clear"
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

Type ":CoverageToggleBranchHits"
Enter
Sleep 1.5s

Screenshot tapes/output/branch.png
