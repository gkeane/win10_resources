# RegChange_Updates_From_MS.ps1
#
# Purpose:
#   This script resets and reconfigures Windows Update settings to ensure updates are received directly from Microsoft,
#   and sets policies for Windows 11 24H2 targeting. It also adjusts power settings to prevent standby on AC power.
#
# What it does:
#   - Stops the Windows Update service (wuauserv)
#   - Removes existing Windows Update Group Policy registry keys and cached policy data
#   - Recreates and configures the Windows Update policy registry keys for direct updates from Microsoft
#   - Sets Windows Update to target Windows 11 24H2
#   - Configures Automatic Updates (AU) subkey with recommended settings
#   - Restarts the Windows Update service
#   - Adjusts power settings to prevent standby on AC and set standby on DC
#
# Usage:
#   Run this script as an administrator in PowerShell. It is intended for use in environments where you need to reset
#   Windows Update policies (e.g., after removing WSUS or other update management) and ensure the device is configured
#   to receive updates directly from Microsoft, targeting Windows 11 24H2.
#
#   Example:
#     powershell.exe -ExecutionPolicy Bypass -File .\RegChange_Updates_From_MS.ps1

Stop-Service wuauserv -Force

Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\GPCache\CacheSet001\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\GPCache\CacheSet002\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue


# Base path
$basePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Create the base key if it doesn't exist
New-Item -Path $basePath -Force

# Set values under WindowsUpdate
Set-ItemProperty -Path $basePath -Name "SetAllowOptionalContent" -Value 1 -Type DWord
Set-ItemProperty -Path $basePath -Name "AllowOptionalContent" -Value 1 -Type DWord
Set-ItemProperty -Path $basePath -Name "ProductVersion" -Value "Windows 11" -Type String
Set-ItemProperty -Path $basePath -Name "TargetReleaseVersion" -Value 1 -Type DWord
Set-ItemProperty -Path $basePath -Name "TargetReleaseVersionInfo" -Value "24H2" -Type String

# Create the AU subkey
$auPath = Join-Path $basePath "AU"
New-Item -Path $auPath -Force

# Set values under WindowsUpdate\AU
Set-ItemProperty -Path $auPath -Name "AutoInstallMinorUpdates" -Value 1 -Type DWord
Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 0 -Type DWord
Set-ItemProperty -Path $auPath -Name "AUOptions" -Value 4 -Type DWord
Set-ItemProperty -Path $auPath -Name "ScheduledInstallDay" -Value 0 -Type DWord
Set-ItemProperty -Path $auPath -Name "ScheduledInstallTime" -Value 13 -Type DWord
Set-ItemProperty -Path $auPath -Name "ScheduledInstallEveryWeek" -Value 1 -Type DWord
Set-ItemProperty -Path $auPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord
Set-ItemProperty -Path $auPath -Name "UseWUServer" -Value 0 -Type DWord
Set-ItemProperty -Path $auPath -Name "IncludeRecommendedUpdates" -Value 1 -Type DWord


Start-Service wuauserv

powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 90

