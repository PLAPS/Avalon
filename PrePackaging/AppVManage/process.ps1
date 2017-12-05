$VerbosePreference = "Continue"
$AppName = 'AppVManage'
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
New-Item -ItemType directory -path "C:\Avalon\logging" -Force
$DStamp = Get-Date -Format dMMMy_ms
Start-Transcript -path "C:\Avalon\logging\${AppName}_Process_${DStamp}.txt"

#region Installation
$InstallFile = 'Setup_AppVManage.msi'
$LocalDest  = 'C:\Avalon'
$ProcessFolder = "$LocalDest\Process"
Import-Module $ProcessFolder\SDModules.psm1
$Exe = "$ProcessFolder\$InstallFile"
$Arguments = "/i `"$Exe`" ALLUSERS=1 /qn"

#Get Version of MSI
$Version = (Get-ExtendedAttributes -P "$Exe" | Select-Object -ExpandProperty Comments) 
$Version = $Version -replace 'AppV_Manage ','' -replace ' 32-bit installer for AnyCPU execution.',''


Start-Process msiexec.exe -ArgumentList $Arguments -Wait
Start-Sleep -Seconds 10
#endregion

#region Post Installation Processes

Rename-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AppV_Manage\AppV_Manage.lnk' "AppV_Manage v$Version.lnk"

#endregion

Stop-Transcript
