##EXE / MSI Based Installation with PVAD
$AppName = 'PackageName' #Package Name (CMSSupervisor is example)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
$LocalDest = 'C:\Avalon'
$ProcessFolder = "$LocalDest\Process"
Import-Module "$ProcessFolder\SDModules.psm1"

#Get Version Information
$Exe = (Get-ChildItem -Path $ProcessFolder | ?{ $_.Name -match "SetupSup" }).Name
Unblock-File "$ProcessFolder\$Exe"
$Release = ($Exe) -replace 'SetupSup_' -replace '.exe',''

#----------------
#Get Version Information (Version info logic)

##If Version is in the EXE or MSI name
#$Exe = (Get-ChildItem -Path $ProcessFolder | ?{ $_.Name -match "SetupSup" }).Name
#Unblock-File "$ProcessFolder\$Exe"
#$Version = ($Exe) -replace 'SetupSup_' -replace '.exe',''

##If Version is in the Comments section of the exe or msi, modify the replace strings to isolate version string
#$Version = (Get-ExtendedAttributes -P "$Exe" | Select-Object -ExpandProperty Comments) 
#$Version = $Version -replace 'AppV_Manage ','' -replace ' 32-bit installer for AnyCPU execution.',''

##If Version is in the File Version Attribute
#$Version = (Get-ExtendedAttributes -Path "$ProcessFolder\filezilla.exe").'File Version'

##Used if developer provides version.txt in release folder
#$Version = (gc "$ProcessFolder\version.txt")

##$Version = 'version info ex: PROD 2017 R1, used only if developer refuses to provide version.txt in release folder'
#----------------

#PVAD Configuration
$PVAD = 'C:\CMS\18MA27'
regedit.exe /s "$ProcessFolder\EnablePVADControl.reg"

#Create Sequence
New-AppvSequencerPackage -Name "$($AppName)_$($Version)" -Path $LocalDest -PrimaryVirtualApplicationDirectory $PVAD -Installer "$ProcessFolder\Process.ps1"
Remove-Item "$ProcessFolder\Sequence.ps1" -Force
