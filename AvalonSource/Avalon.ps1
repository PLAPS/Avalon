$ErrorActionPreference = 'Continue'

#region Load and configure window xml information
    [Void][System.Reflection.Assembly]::LoadwithPartialName('PresentationFramework')
    $WindowXML = [XML]((Get-Content -Path $PSScriptRoot\Resources\WpfApplication1\WpfApplication1\MainWindow.xaml).Replace('mc:Ignorable="d"', '').Replace('x:N', 'N') -replace '^Win.*', '<Window')
    $WindowXML.Window.Class = 'System.Windows.Window'
    Try { $Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $WindowXML)) } Catch { Write-Error -Message 'Could not load window information.' }
    $Window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create(('{0}\Resources\hllambert.ico' -f $PSScriptRoot))
    $AL = New-Object -TypeName PSObject
    $NodeList = $WindowXML.SelectNodes('//*[@Name]')
    ForEach ($Node in $NodeList) { $AL | Add-Member -MemberType NoteProperty -Name $Node.Name -Value $Window.FindName($Node.Name) }
#endregion


$PackagePath = "$PSScriptRoot\..\PrePackaging"

Function Get-Packages {
    $AL.listView.items.Clear()
    ForEach ($File in Get-ChildItem -Recurse -Path $PackagePath | ? {$_.Name -match '.ps1' -and $_.Name -notmatch 'sequence' -and $_.Name -notmatch 'process'} | Sort-Object) {
        $NewItem = New-Object System.Windows.Controls.ListViewItem 
        $NewItem.Content = $File.BaseName
        $NewItem | Add-Member -MemberType NoteProperty -Name 'FullName' -Value $File.FullName
        $AL.listView.AddChild($NewItem)
    }
}
Get-Packages 

 
$AL.GetPackages.Add_Click({
    Get-Packages 
})

$AL.CreatePackage.Add_Click({
Start-Process -FilePath 'powershell.exe' -ArgumentList "-File `"$($AL.listView.SelectedItem.FullName)`""
})


$Window.ShowDialog() | Out-Null
