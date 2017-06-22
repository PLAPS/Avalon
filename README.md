# Avalon
App-V Package Sequencing Automation

Run Avalon.ps1 from AvalonSource directory

Configure your packaging scripts in PrePackaging directory

See PrePackaging\AppVManage for an example

Each package must have its own folder under PrePackaging, containing the following:

AppName.ps1 (renamed to match the application and containing folder (without spaces preferred))

Sequence.ps1

Process.ps1

Application installation files
    
View packaging script templates in Templates directory
