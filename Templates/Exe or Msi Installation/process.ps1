$AppName = 'AppName' #The application name, as appears on Start Menu

$LocalDest = 'C:\Avalon'
$ProcessFolder = "$LocalDest\Process"
Import-Module "$ProcessFolder\SDModules.psm1"
$Exe = "application.exe"

#----------------

#Get Version Information (Version info logic)

##If Version is in the EXE or MSI name##
#$Exe = (Get-ChildItem -Path $ProcessFolder | ?{ $_.Name -match "SetupSup" }).Name
#Unblock-File "$ProcessFolder\$Exe"
#$Release = ($Exe) -replace 'SetupSup_' -replace '.exe',''

##If Version is in the Comments section of the exe or msi, modify the replace strings to isolate version string##
#$Version = (Get-ExtendedAttributes -P "$Exe" | Select-Object -ExpandProperty Comments) 
#$Version = $Version -replace 'AppV_Manage ','' -replace ' 32-bit installer for AnyCPU execution.',''

##If Version is in the File Version Attribute##
#$Version = (Get-ExtendedAttributes -Path "$ProcessFolder\$AppName\filezilla.exe").'File Version'

#----------------

#Install Application
$Arguments = "/hide_progress --silent --TargetDir=C:\CMS\18MA27"
Start-Process $ProcessFolder\$Exe -ArgumentList $Arguments -Wait
Start-Sleep -Seconds 45

#Post Installation Processes


#Examples
#----------------
#regedit.exe /s "$ProcessFolder\HKCU.reg"
#Rename-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Avaya\CMS Supervisor R18\CMS Supervisor R18 -- English.lnk' "CMS Supervisor R18 $($Release).lnk"
#Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Avaya\CMS Supervisor R18\CMS Supervisor R18 Help -- English.lnk' -Force
#Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Avaya\CMS Supervisor R18\Readme.txt.lnk' -Force
#----------------