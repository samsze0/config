# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Invoke-Expression (& 'starship' init powershell --print-full-init | Out-String)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function wm {
  glazewm --config="$([Environment]::GetEnvironmentVariable('userprofile'))\.config\glazewm\config.yaml"
}

function kbd {
  ~/.config/kmonad/kmonad.exe "$([Environment]::GetEnvironmentVariable('userprofile'))/.config/kmonad/kmonad.kbd"
}