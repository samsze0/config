# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-Alias open ii

Invoke-Expression (& starship init powershell --print-full-init | Out-String)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

New-Variable -Name "ConfigPath" -Visibility Public -Value "$([Environment]::GetEnvironmentVariable('userprofile'))\.config"


function whkd_restart {
  if (Get-Process whkd -ErrorAction SilentlyContinue)
  {
    taskkill /f /im whkd.exe
  }
  Start-Process whkd -WindowStyle hidden
}

function setup {
  param (
    $PowerShell,
    $WindowsTerminalPath,
    $PowerToys,
    $RawAccel,
    $FancyWMPath
  )
  if ($PowerShell) {
    sudo ln -s "$ConfigPath\powershell\profile.ps1" "$([Environment]::GetEnvironmentVariable('userprofile'))\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
  }
  if ($WindowsTerminalPath) {
    Remove-Item "$WindowsTerminalPath\settings.json"
    sudo ln -s "$ConfigPath\windows-terminal\settings.json" "$WindowsTerminalPath\settings.json"
  }
  if ($PowerToys) {
    sudo ln -s "$ConfigPath\powertoys\keyboard-manager\settings.json" "$([Environment]::GetEnvironmentVariable('userprofile'))\AppData\Local\Microsoft\PowerToys\Keyboard Manager\settings.json"
    sudo ln -s "$ConfigPath\powertoys\keyboard-manager\default.json" "$([Environment]::GetEnvironmentVariable('userprofile'))\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json"
  }
  if ($RawAccel) {
    sudo ln -s "$ConfigPath\rawaccel\settings.json" "$ConfigPath\rawaccel\RawAccel\settings.json"
  }
  if ($FancyWMPath) {
    sudo ln -s"$ConfigPath\fancywm\settings.json" "$FancyWMPath\settings.json"
  }
}