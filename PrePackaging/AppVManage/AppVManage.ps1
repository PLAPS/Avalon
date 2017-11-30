#vSphere and Sequencer VM Configuration
	$Sequencer = 'ComputerName' #Computer name of Sequencer VM
	Write-Verbose "Please Enter Credentials for VSphere (Domain\User)"
    	$DomCred = Get-Credential -Message 'VSphere Credentials'
    	$VIServerName = 'VIServer.domain.com' #vSphere VI Server Name
	$SnapShotName = 'SnapshotName' #Sequencer VM SnapShot Name

##DO NOT MODIFY BELOW THIS LINE##	

#Avalon Configuration
	$VerbosePreference = "continue"
    	$AppSourceName = Split-Path -Path $PSScriptRoot -Leaf
	$Source = "$PSScriptRoot\..\..\PrePackaging\$AppSourceName"
	$Repo = "$PSScriptRoot\..\..\CompletedPackages"
	$SDModuleSource = "$PSScriptRoot\..\..\Modules\SDModules.psm1" #Location of Avalon Custom Functions Script

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
        	$VMInfo = Get-VMGuest $Sequencer
        	$SeqIP = $VMinfo.IPAddress
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
	New-PSDrive -Name M -PSProvider FileSystem -Root $LocalRoot -Credential $DomCred -Persist
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
	$PackageFolder = (Get-ChildItem -Recurse $LocalDest -Exclude Process -Directory).name
	Copy-Item $LocalDest\$PackageFolder $Repo -Recurse -Exclude Process
	If (Test-Path -Path $Repo\$PackageFolder) {
		Write-Verbose "Package copied to Repository Successfully"
		} Else { Copy-Item $LocalDest\$PackageFolder $Repo -Recurse -Exclude Process }
	If (!(Test-Path -Path $Repo\$PackageFolder)) {
		Write-Verbose "WARNING: UNABLE TO COPY PACKAGE TO REPOSITORY!"
		pause
		exit }

#Reset VM to SnapShot
	Write-Verbose "Resetting VM to SnapShot"
	Get-Snapshot -VM $Sequencer -Name $SnapShotName | Set-VM -VM $Sequencer -Confirm:$false
	Write-Verbose "Package Completed!"
