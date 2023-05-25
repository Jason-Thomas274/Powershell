$printers = @("10.58.31.235", "10.58.30.238")
$printers.count

foreach ($printer in $printers)
{
    $ping_printer = Test-NetConnection $printer | Select-Object -Property PingSucceeded
    If ([bool]$ping_printer -eq $true) {
    Write-Host "$printer is online"
    If ([bool]$ping_p -eq $false) {
    Write-Host "$printer is offline"
    }

}
}
PowerShell -NoExit
#$printers.count
$printers = @("10.58.31.235", "10.58.30.238")
$printers_online =@()
$printers_offline = @()

foreach ($printer in $printers)
{
    $ping_printer = Test-NetConnection $printer | Select-Object -Property PingSucceeded
    If ([bool]$ping_printer -eq $true) {
    Write-Host "$printer is online"
    If ([bool]$ping_printer -eq $false) {
    Write-Host "$printer is offline"
    }

}
}
PowerShell -NoExit

