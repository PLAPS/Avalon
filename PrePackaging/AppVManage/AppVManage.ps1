#vSphere and Sequencer VM Configuration
	$Sequencer = 'MachineName' #Computer name of Sequencer VM
    $ODUser = "$Sequencer\ODSnap" #Local user admin account on Sequencer (Off Domain User)
    $ODPFile = "$PSScriptRoot\..\..\AvalonSource\Pd.txt" #Encrypted password for $ODUser account
    $ODKFile = "$PSScriptRoot\..\..\AvalonSource\Avalon.key" #Encryption key for password
    $ODKey = Get-Content $ODKFile
    $ODCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ODUser, (Get-Content $ODPFile | ConvertTo-SecureString -Key $ODKey)
	Write-Verbose "Please Enter Credentials for VSphere (Domain\User)"
    $Global:DomCred = Get-Credential -Message 'VSphere Credentials'
    $VIServerName = 'vSphereServerName' #vSphere VI Server Name
    $SnapShotName = 'ODSnap4' #Sequencer VM SnapShot Name

##DO NOT MODIFY BELOW THIS LINE##	

#Avalon Configuration
	$VerbosePreference = "continue"
    $AppSourceName = Split-Path -Path $PSScriptRoot -Leaf
	$Source = "$PSScriptRoot\..\..\PrePackaging\$AppSourceName"
	$Repo = "$PSScriptRoot\..\..\CompletedPackages"
	$SDModuleSource = "$PSScriptRoot\..\..\Modules\SDModules.ps1" #Location of Avalon Custom Functions Script

#region PowerCLI
	Write-Verbose "Starting VM"
	Add-PSSnapin -Name VMware.VimAutomation.Core
    $ErrorActionPreference = 'SilentlyContinue'
    Connect-VIServer -Server $VIServerName -Protocol https -Credential $DomCred
    Get-Snapshot -VM $Sequencer -Name $SnapShotName | Set-VM -VM $Sequencer -Confirm:$false
	Write-Verbose "Waiting for VM IP Address"
    Start-VM -VM $Sequencer
    Do {
        Start-Sleep -s 30
        $SeqIP = Get-VM -Name $Sequencer | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} | Select -Expand IPAddress
    } While ($SeqIP.Length -eq 0)
	Write-Verbose "Completed Starting VM"
#endregion

#Copy install files to Sequencer (C:\Avalon)
	Write-Verbose "Starting File Copy to VM"
    $LocalRoot = "\\$SeqIP\C$"
	$LocalDest  = "$LocalRoot\Avalon"
    If (Test-Path $LocalRoot ) {
        Net Use /delete $LocalRoot
	}
	If (Test-Path M:) {
		Remove-PSDrive M -Force
	}
	New-PSDrive -Name M -PSProvider FileSystem -Root $LocalRoot -Credential $ODCred -Persist
    $ProcessFolder = "$LocalDest\Process"
	New-Item -ItemType directory -Path $ProcessFolder -Force
	Copy-Item $SDModuleSource "$ProcessFolder\SDModules.psm1" -Force
	Copy-Item $Source\* $ProcessFolder -Recurse -Force -Exclude Sequence.ps1
	Copy-Item $Source\Sequence.ps1 $ProcessFolder\Sequence.ps1
	Write-Verbose "Completed Attempt to Copy Files to VM"

#Wait for Package to Complete
	Write-Verbose "Waiting for AppV Package to Complete"
	While (!(Test-Path $LocalDest\*\*.appv)) {
		Start-Sleep -Seconds 10
	}
	Start-Sleep -Seconds 60
	Write-Verbose "AppV Package Completed"
	
#Copy Package to Repository
	Write-Verbose "Attempting to Copy AppV Package to Repository"
    Remove-PSDrive M -Force
	New-PSDrive -Name M -PSProvider FileSystem -Root $LocalRoot -Credential $ODCred -Persist
	Copy-Item $LocalDest\* $Repo -Recurse -Exclude Process
    Remove-PSDrive M -Force
	Write-Verbose "Completed Attempt to Copy AppV Package to Repository"

#Reset VM to SnapShot
	Write-Verbose "Resetting VM to SnapShot"
	Get-Snapshot -VM $Sequencer -Name $SnapShotName | Set-VM -VM $Sequencer -Confirm:$false
	Write-Verbose "Package Completed!"
