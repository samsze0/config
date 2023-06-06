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

function setup {
  param (
    $PowerShell,
    $WindowsTerminalPath,
    $PowerToys
  )
  if ($PowerShell) {
    sudo ln -s "$([Environment]::GetEnvironmentVariable('userprofile'))\.config\powershell\profile.ps1" "$([Environment]::GetEnvironmentVariable('userprofile'))\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
  }
  if ($WindowsTerminalPath) {
    Remove-Item "$WindowsTerminalPath\settings.json"
    sudo ln -s "$([Environment]::GetEnvironmentVariable('userprofile'))\.config\windows-terminal\settings.json" "$WindowsTerminalPath\settings.json"
  }
  if ($PowerToys) {
    sudo ln -s "$([Environment]::GetEnvironmentVariable('userprofile'))\.config\powertoys\keyboard-manager\settings.json" "$([Environment]::GetEnvironmentVariable('userprofile'))\AppData\Local\Microsoft\PowerToys\Keyboard Manager\settings.json"
    sudo ln -s "$([Environment]::GetEnvironmentVariable('userprofile'))\.config\powertoys\keyboard-manager\default.json" "$([Environment]::GetEnvironmentVariable('userprofile'))\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json"
  }
}