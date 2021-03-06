$AppName = 'AppVManage'
$InstallFile = 'Setup_AppVManage.msi'

$LocalDest = 'C:\Avalon'
$ProcessFolder = "$LocalDest\Process"

New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
Set-ItemProperty HKCR:\Microsoft.PowerShellScript.1\Shell '(Default)' 0
Import-Module "$ProcessFolder\SDModules.psm1"
$Exe = "$ProcessFolder\$InstallFile"
Unblock-File $Exe

$Version = (Get-ExtendedAttributes -P "$Exe" | Select-Object -ExpandProperty Comments) 
$Version = $Version -replace 'AppV_Manage ','' -replace ' 32-bit installer for AnyCPU execution.',''

New-AppvSequencerPackage -Name "$($AppName)_v$Version" -Path $LocalDest -Installer "$ProcessFolder\Process.ps1"
Remove-Item "$ProcessFolder\Sequence.ps1" -Force
