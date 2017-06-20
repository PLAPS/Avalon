$AppName = 'Application Name' #The application name, as appears on Start Menu
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