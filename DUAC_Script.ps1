# Disable UAC to bypass error "A required privledge is not held by client"
$UAC = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system"
Set-ItemProperty -Path $UAC -Name "EnableLUA" -Value 0 -Type "DWord"

$RUAC = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\system"
Set-ItemProperty -Path $RUAC -Name "EnableLUA" -Value 0 -Type "DWord"