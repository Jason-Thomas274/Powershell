<#
.SYNOPSIS
    -Browser history for Edge, Chrome capture and export to C:\Temp for file retrieval
    -Change Username before running script
.NOTES
    Author: Jason Thomas

    Version:
    1.0 - 2/1/23 - Script Created
#>
Install-Module PSSQLite -Force
Import-Module PSSQLite
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Manually change username before running script
$UserName = "username"
$EDS = "C:\Temp\EdgeH"
$CDS = "C:\Temp\ChromeH"
function Get-BrowserScape {
    $BL = "HKLM:\SOFTWARE\Clients\StartMenuInternet"
    $BKey = Get-ChildItem -Path $BL | Format-List -Property 'PSChildName'
    return $BKey
}
function Get-BrowserHistory {
    param ([string]$User)
    $EHistory - Copy-Item -Path "C:\Users\$UserName\AppData\Local\Microsoft\Edge\User Data\Default\History" -Destination $EDS
    $CHistory = Copy-Item -Path "C:\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History" -Destination $CDS
    $EHistory
    $CHistory
    #FHISTORY
}
function Get-DataBaseInfo {
    param ([string]$ES, [string]$CS) # Source
    $Q = "Select id, url, title,
    datetime(last_visit_time / 1000000 + (strftime('%s', '1601-01-01')), 'unixepoch', 'localtime') as Last Access Time'
    FROM urls
    ORDER BY last_visit_time DESC"
    Invoke-SqliteQuery -Query $Q -DataSource $ES
    Invoke-SqliteQuery -DataSource $ES -Query $Q | ConvertTo-Html > C:\temp\EdgeHistory.html
    Invoke-SqliteQuery -Query $Q -DataSource $CS
    Invoke-SqliteQuery -DataSource $CS -Query $Q | ConvertTo-Html > C:\temp\ChromeHistory.html
}
function Remove-DS {
    Remove-Item -Path $EDS
    Remove-Item -Path $CDS
}
try {
    Get-BrowserHistory -User $UserName
    Get-DataBaseInfo -ES $EDS -CS $CDS
    Get-BrowserScape
    Write-Output "Success"
    Remove-DS
}
catch {
    Write-Host "An error has occured"
    # Un-comment if logs are needed, these are saved on the target local machine
    # $eM = $_.Exception.Message
    # $eR = $_.Exception
    # $eM | Out-File -FilePath "C:\Temp\error.txt"
    # $eR | Export-Clixml -Path "C:\Temp\error.xml"
}
Uninstall-Module PSSQLite -Force
