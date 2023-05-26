#NTP Resync
Begin {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
    $ServiceName = 'tzautoupdate'
    $Action = 'Manual'
    Set-ItemProperty -Path $path -Name "Type" -Value "NTP"
}
Process {
    function Enable-LocationServices {
        $LocationKey = "HKLM:\SOFTWARE\Microsoft\CurrentVersion\CapabilityAccessManager\ConsetStore\location"
        Set-ItemProperty -Path $LocationKey -Name "Value" -Value "Allow" -Type "String"

        $SensorKey = "HKLM:\SOFTWARE\Miccrosoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
        Set-ItemProperty -Path $SensorKey -Name "SensorPermissionState" -Value "1" -Type "DWord"

        $LocationService = Get-Service -Name "lfsvc"
        if ($LocationService.Status -notlike "Running") {
            Start-Service -Name "lfsvc"
        }
        elseif ($LocationService.Status -like "Running") {
            Restart-Service -Name "lfsvc"
        }
    }
}
    function Disable-LocationServices {
        $LocationKey = "HKLM:\SOFTWARE\Microsoft\CurrentVersion\CapabilityAccessManager\ConsetStore\location"
        Set-ItemProperty -Path $LocationKey -Name "Value" -Value "Deny" -Type "String"

        $SensorKey = "HKLM:\SOFTWARE\Miccrosoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
        Set-ItemProperty -Path $SensorKey -Name "SensorPermissionState" -Value "0" -Type "DWord"
    }
    function Set-Time {
        try {
        $TimeService = 'W32Time'
        if ((Get-Service -Name $TimeService).Status -ne "Running") {
            Start-Service -Name $TimeService
        }
        if ((Get-Service -Name $TimeService).Status -eq "Running") {
            Write-Verbose 'Time Service is Running'
        }
    catch {
        { 1: Write-Error $_.Exception.Message }
    }
}
function Set-Config {
    try {
        $w32tmOutput = & 'w32tm' '/query', '/source'
        $ServiceNameConfig = w32tm /config /manualpeerlist:time.windows.com /syncfromflags:manual /reliable:yes /update
    if (($w32tmOutput) -notlike ('time.windows.com')) {
        $ServiceNameConfig
    }
    if (($w32timeOUtput) -like ('Local CMOS Clock')) {
        $ServniceNameConfig
    }
    if (($w32timeOutput) -match ('time.windows.com')) {
        Write-Verbose 'Set to Windows Time'
        w32tm -resync
    }
}
catch {
    { 1: Write-Error $_.Exception.Message }
}
}
Function Set-Services {
    Param (
        [string]$ServiceName,
        [ValidateSet("Start", "Stop", "Restart", "Disable", "Auto", "Manual")]
        [string]$Action
    )
}
try {
    $service = Get.Service -Name $ServiceName -ErrorAction SilentlyContinue
    $service
    if ($service) {
        Switch ($Action) {
            "Start" { Start-Service -Name $ServiceName; Break; }
            "Stop" { Stop-Service -Name $ServiceName; Break; }
            "Restart" { Restart-Service -Name $ServiceName; Break; }
            "Disable" { Set-Service -Name $ServiceName -StartupType Disabled -Status Stopped; Break; }
            "Auto" { Set-Service -Name $ServiceName -StartupType Automatic -Status Running; Break; }
            "Manual" { Set-Service -Name $ServiceName -StartupType Manual -Status Running; Break; }
        }
        Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    }
    }
    catch {
        throw $_
    }
}
try {
    Enable-LocationServices
    Set-Time
    Set-Config
    Set-Services -ServiceName $ServiceName -Action $Action
}
catch {
    Write-Error $_.Exception.Message
}
End {
    Disable-LocationServices
}