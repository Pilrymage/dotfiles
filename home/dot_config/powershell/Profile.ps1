Set-PSReadLineOption -EditMode Emacs
Set-Alias -Name scurl -Value (Join-Path $HOME "scoop\shims\curl.exe")
Import-Module PSFzf
# Optional: Set standard fzf keybindings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -TabExpansion

