#If corrupted windows updates, clear C:\Windows\SoftwareDistribution\Download
#C:\Users\Administrator\Documents\WindowsPowerShell\Modules (Modules are stored in this path when CurrentUser installing Module)
#C:\Program Files\WindowsPowerShell\Modules (Modules are stored in this path when ALlUsers scope is provided)
#C:\Windows\system32\WindowsPowerShell\v1.0\Modules (Default path for Module, Windows Updates/PowerShell Version or Module is installed in this location)

#To remove PSWindowsUpdate module
    #$Module = Get-Module PSWindowsUpdate
    #Remove-Module $Module.Name
    #Remove-Item $Module.ModuleBase -Recurse -Force
#To remove PSWindowsUpdate if path is unknown
    #Uninstall-Module PSWindowsUpdate
#Get-ExecutionPolicy 
#Set-ExecutionPolicy RemoteSigned
#Set-ExecutionPolicy Unrestricted -Forced

$CurrentWindows = "OsVersion=10.0.19044" #change to current version of Windows
$CurrentVersion = Get-ComputerInfo OsVersion  
$ComputerVersion = $CurrentVersion -match "19044"
$Message = "Perform Windows Updates? Y/N"
$Response = "" 

Write-Host "Current Windows Version: $CurrentWindows"
Get-ComputerInfo CsDNSHostName, CsUserName, WindowsProductName, OsVersion, CsSystemSKUNumber


If($ComputerVersion -eq "true")
{
    Write-Host "Computer is up to date with version $CurrentVersion"
}
If($ComputerVersion -ne "true")
{
    Write-Host "Computer is not up to date. Current version: $CurrentVersion, Latest version: $CurrentWindows"
    $Response = Read-Host -Prompt $Message        
       if ($Response -eq "Y")
       {
           # Install-Module PSWindowsUpdate -Scope CurrentUser #installs PSWindowsUpdate Package, 3rd party maintained
           # Get-WindowsUpdate 
           # Install-WindowsUpdate

            #Uncomment next two lines if you want to update other Microsoft products as well, set to AutoReboot
            #Add -WUServiceManager -MicrosoftUpdate
            #Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot 
       }
       if ($Response -eq "N")
       {
           Write-Host "Canceled Windows Updates"
       }
}

# Verify that the module installed, type the following command to see all the commands of the module
# Get-Command -Module PSWindowsUpdate


