#Logging Setup
  $VerbosePreference = "Continue"
  $AppName = 'Application Name' #The application name, as appears on Start Menu
	$ErrorActionPreference="SilentlyContinue"
	Stop-Transcript | out-null
	$ErrorActionPreference = "Continue"
	New-Item -ItemType directory -path "C:\Avalon\logging" -Force
	$DStamp = Get-Date -Format dMMMy_ms
	Start-Transcript -path "C:\Avalon\logging\${AppName}_Process_${DStamp}.txt"
  
$LocalDest = 'C:\Avalon'
$ProcessFolder = "$LocalDest\Process"
Import-Module "$ProcessFolder\SDModules.psm1"
$Version = (Get-ExtendedAttributes -Path "$ProcessFolder\$AppName\AppName.exe").'File Version' #Use correct Version Logic here
$Exe = 'AppName.exe' #Exe name
$InstallPath = "$env:programfiles\$AppName"
New-Item -ItemType directory -Path $InstallPath -Force
Copy-Item "$ProcessFolder\$AppName\*" "$InstallPath" -Recurse -Force
New-Item -ItemType directory -Path "$env:USERPROFILE\Start Menu\Programs\AppName $Version"

$AppLocation = "$InstallPath\$Exe"
$WshShell = New-Object -ComObject WScript.Shell
#$Shortcut = $WshShell.CreateShortcut($env:USERPROFILE + "\Start Menu\Programs\$AppName v$Version.lnk") #Root of Start Menu
$Shortcut = $WshShell.CreateShortcut($env:USERPROFILE + "\Start Menu\Programs\AppName $Version\$AppName v$Version.lnk") #Folder on Start Menu
$Shortcut.TargetPath = $AppLocation
$Shortcut.IconLocation = "$InstallPath\AppName.exe, 0" #Update with the icon name
$Shortcut.WorkingDirectory ="$InstallPath"
$Shortcut.Save()

Stop-Transcript
