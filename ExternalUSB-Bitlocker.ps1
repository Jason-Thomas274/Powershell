<#
.SYNOPSIS
    -When ran, waits for external USB drive plug in
    -Encrypts device to be set up with bitlocker standards
    -Recovery key saved to local/cloud locations
.NOTES
    Author: Jason Thomas
#>
Import-Module BitLocker
set-location C:\Users
Get-ChildItem

#Change path to priviledged profile -> confirmation -> used for later recovery key location export
$CurrentUser = read-host `n"Enter the current user name from list"   
$Path = set-location "C:\Users\$CurrentUser\OneDrive - NAME\Documents" # change "NAME" to location
#Verify current external USB drives connected to physical host
$ExternalDrives = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
#Write to console -> request user input selection for drive letter
$DriveLetterSelect = Read-Host `n"Current USB external drives attached = [$ExternalDrives]`nPlease enter only a drive letter"
#Convert string to upper casing to avoid potential invalid input
$UserDriveInput = ($DriveLetterSelect+":").ToUpper()
$UserPasswordInput = Read-Host "Please enter a 8 character minimum password to be applied to the External USB Drive"

#Verify password length, where bit-locker password requirement length > 8 characters
if ($UserPasswordInput.length -ge 8) {
    $SecurePassword = ConvertTo-SecureString $UserPasswordInput -AsPlainText -Force
}
Else {
    Write-Host "Failed to meet minimum 8 character length, exiting..."
    break
    PowerShell -NoExit
}
#Verify user input selection
$UserInput = Read-Host "If selected drive [$UserDriveInput] and password: $UserPasswordInput is correct, please type 'yes' to proceed or 'q' to quit"
$UserInputAnswer = (($UserInput).ToUpper())

#Function to apply bitlocker to selected drive
function Bitlock_Drive($DriveLetter) {
    Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod Aes256 -UsedSpaceOnly -SkipHardwareTest -Password $SecurePassword -PasswordProtector
    Get-BitLockerVolume -MountPoint $DriveLetter | Add-BitLockerKeyProtector -RecoveryPasswordProtector
    (Get-BitLockerVolume -MountPoint $DriveLetter).KeyProtector.recoverypassword > $Path\BitLocker_Key.txt
}
if ($UserInputAnswer -eq "YES") {
    Try{
        Bitlock_Drive($UserDriveInput):
        Manage-BDE -Protectors -Get $UserDriveInput
        Write-Host "**Drive [$UserDriveInput] has been successfully set up with Bitlocker!`n**A Recovery Key has been saved in $path as a text file named BitLocker_Key.txt`n`n`n"
        PowerShell -NoExit
    }
    Catch{
        Write-Error "Error, exiting..."
        exit
    }
}
if ($UserInputAnswer -eq "Q") {
    Write-Host "Quitting..."
    break
}
Else {
    Write-Host "Invalid Input, exiting..."
    exit
    }
PowerShell -NoExit
