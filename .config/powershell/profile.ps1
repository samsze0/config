# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-Alias open ii

Invoke-Expression (& starship init powershell --print-full-init | Out-String)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function kbd {
  ~/.config/kmonad/kmonad.exe "$([Environment]::GetEnvironmentVariable('userprofile'))/.config/kmonad/kmonad.kbd"
}

function whkd_reload {
  taskkill /f /im whkd.exe
  Start-Process whkd -WindowStyle hidden
}

function setup {
  param (
    $PowerShell,
    $WindowsTerminalPath,
    $PowerToys,
    $RawAccel
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
  if ($RawAccel) {
    sudo ln -s "$([Environment]::GetEnvironmentVariable('userprofile'))\.config\rawaccel\settings.json" "$([Environment]::GetEnvironmentVariable('userprofile'))\.config\rawaccel\RawAccel\settings.json"
  }
}