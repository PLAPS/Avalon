       Function Get-MSIInformation {
        Param ([Parameter(Mandatory = $true)] [Alias('P')] [String] $Path)
        $FileResult = Get-Item -Path $Path -ErrorAction SilentlyContinue
        If (($FileResult | Select -ExpandProperty Extension) -ne '.msi') {
            Write-Error -Message 'Either the file was not found, or it is not a MSI file'
        } Else {
            $Result = New-Object -TypeName PSObject
            $InstallerObject = New-Object -ComObject WindowsInstaller.Installer
            $MSIDB = $InstallerObject.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $InstallerObject, @($FileResult.FullName, 0))
            $MSIDBView = $MSIDB.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDB, ('Select * From Property'))
            $MSIDBView.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $MSIDBView, $null)

            While (($Record = $MSIDBView.GetType().InvokeMember("Fetch", 'InvokeMethod', $null, $MSIDBView, $null)) -ne $null) { $Result | Add-Member -MemberType NoteProperty -Name $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1) -Value $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 2) }
        }
        Return $Result
    }

    Function Get-ExtendedAttributes {
        Param ([Parameter(Mandatory = $true)] [Alias('P')] [String] $Path)
        $RealFile = Get-Item -Path $Path
        $FolderNamespace = (New-Object -ComObject Shell.Application).NameSpace($RealFile.DirectoryName)
        $FileObject = $FolderNamespace.ParseName($RealFile.Name)
        $ExtendedNameMap = @{}
        For ($i = 0; $i -le 287; $i++) {
            $Definition = $FolderNamespace.GetDetailsOf($null, $i)
            If ($ExtendedNameMap.ContainsKey($Definition)) { $Definition += $i }
            If ($Definition.Length -gt 0) { $ExtendedNameMap.Add($Definition, $i) }
        }

        $ExtendedAttributes = New-Object PSObject 
        $ExtendedAttributes.PSObject.TypeNames[0] = 'Custom.IO.File.Metadata'
        $ExtendedAttributes | Add-Member -MemberType NoteProperty -Name PSPath -Value $RealFile.PSPath
        ForEach ($AttributeSet in $ExtendedNameMap.GetEnumerator() | Sort-Object -Property Key) {
            $AttributeData = $FolderNamespace.GetDetailsOf($FileObject, $AttributeSet.Value)
            If ($AttributeData) { $ExtendedAttributes | Add-Member -MemberType NoteProperty -Name $AttributeSet.Key -Value $AttributeData }
        }
        Return $ExtendedAttributes
    }
    Function Get-MsiDatabaseVersion {
        Param ([IO.FileInfo] $FilePath)
        try {
            $windowsInstaller = New-Object -com WindowsInstaller.Installer
            $database = $windowsInstaller.GetType().InvokeMember(
                    "OpenDatabase", "InvokeMethod", $Null, 
                    $windowsInstaller, @($FilePath.FullName, 0)
                )

            $q = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
            $View = $database.GetType().InvokeMember(
                    "OpenView", "InvokeMethod", $Null, $database, ($q)
                )

            $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)

            $record = $View.GetType().InvokeMember(
                    "Fetch", "InvokeMethod", $Null, $View, $Null
                )

            $productVersion = $record.GetType().InvokeMember(
                    "StringData", "GetProperty", $Null, $record, 1
                )

            $View.GetType().InvokeMember("Close", "InvokeMethod", $Null, $View, $Null)

            return $productVersion

        } catch {
            throw "Failed to get MSI file version the error was: {0}." -f $_
        }
    }
	Function Stop-Processes {
    param(
        [parameter(Mandatory=$true)] $processName,
                                     $timeout = 5
    )
    $processList = Get-Process $processName -ErrorAction SilentlyContinue
    if ($processList) {
        # Try gracefully first
        $processList.CloseMainWindow() | Out-Null

        # Wait until all processes have terminated or until timeout
        for ($i = 0 ; $i -le $timeout; $i ++){
            $AllHaveExited = $True
            $processList | % {
                $process = $_
                If (!$process.HasExited){
                    $AllHaveExited = $False
                }                    
            }
            If ($AllHaveExited){
                Return
            }
            sleep 1
        }
        # Else: kill
        $processList | Stop-Process -Force        
    }
}
