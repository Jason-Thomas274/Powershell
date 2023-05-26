<#
.NOTES
    Author:   Jason Thomas
.SYNOPSIS
    Configure forticlient VPN
.DESCRIPTION
    Disconnect from any current VPN connections before running script
    Change yourdomain.com to your actual domain
#>

#$hash = @{ 'Network Type' = $cN; 'Interface' = $cC; 'Forticlient Version' = $fV; 'DNS Suffix' = $sL; 'IKE Service' = $cS }
function Set-Forti {
    $FoV = Get-CimInstance -Query "SELECT * from Win32_Product WHERE name LIKE 'FortiClient%'" 
    $fC = "6.4.6.1658"
    $fV = $FoV.Version
    if ($fV -eq $fC) {
        return $fV = $FoV.Version
    }
    else {
        return $fV = "Recommended: Upgrade to 6.4.6.1658, Current: $fV"
    }
} Set-Forti
function Set-Connection {
    # $cN.GetType()
    $cN = Get-NetConnectionProfile | Select-Object -ExpandProperty NetworkCategory
    $cC = Get-NetConnectionProfile | Select-Object -ExpandProperty InterfaceAlias
    while ($cN -ne 'Private') {
        Set-NetConnectionProfile -InterfaceAlias * -NetworkCategory "Private"
        return $cN
    }
    if ($cC -like '*Ethernet*') {   
        return $cC
    }
    else {
        return $cC = "Recommended: Connect via ethernet. Current: $cC"
    }
} Set-Connection
function Set-SearchList {
    $regC = "HKLM:SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    $sL = Get-ItemProperty -Path $regC -PSProperty "SearchList" | Select-Object -ExpandProperty SearchList
    if ($sL -eq 'yourdomain.com') {
        return $sL
    }
    else {
        Set-ItemProperty -Path $regC -name "SearchList" -Value "yourdomain.com" -Type "String"
    }
} Set-SearchList
function Set-Services {
    $cS = Get-Service IKEEXT | Select-Object -ExpandProperty Status
    Set-Service -name IKEEXT -StartupType Automatic
    Start-Service -name IKEEXT
    return $cS 
} Set-Services
#$hash

