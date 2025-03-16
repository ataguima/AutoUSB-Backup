<#
.SYNOPSIS
    PowerShell script to perform backup of selected files to a USB drive.
.DESCRIPTION
    This script copies files from specified user folders to a USB drive with a given label. Files larger than 10MB are ignored.
.PARAMETER DriveLabel
    The label of the USB drive where the files will be copied.
.PARAMETER SourceFolders
    The list of source folders whose files will be copied.
.PARAMETER DestinationSubfolder
    The name of the subfolder on the USB drive where the files will be stored.
.PARAMETER MaxFileSize
    The maximum file size to be copied (in bytes).
.EXAMPLE
    .\backup-script.ps1 -DriveLabel "MY_DRIVE" -SourceFolders "$env:USERPROFILE\Documents" -DestinationSubfolder "Backup" -MaxFileSize 10485760
.NOTES
    Author: Ataides
    Date: March 2025
#>

param(
    [string]$DriveLabel = 'MY_DRIVE',  # USB drive label
    [string[]]$SourceFolders = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"
    ),  # Source folders
    [string]$DestinationSubfolder = 'Data',  # Destination subfolder name
    [long]$MaxFileSize = 10485760  # Max file size in bytes (10MB)
)

# Detect the USB drive with the specified label
$drive = [System.IO.DriveInfo]::GetDrives() | Where-Object {
    $_.DriveType -eq 'Removable' -and $_.IsReady -and $_.VolumeLabel -eq $DriveLabel
} | Select-Object -First 1

if ($drive) {
    # Set the root destination and create if necessary
    $destRoot = Join-Path $drive.Name $DestinationSubfolder
    if (-not (Test-Path $destRoot)) { New-Item -Path $destRoot -ItemType Directory -Force | Out-Null }

    foreach ($folder in $SourceFolders) {
        if (Test-Path $folder) {
            # Create a destination subfolder named after the source folder
            $subfolderName = Split-Path $folder -Leaf
            $dest = Join-Path $destRoot $subfolderName
            if (-not (Test-Path $dest)) { New-Item -Path $dest -ItemType Directory -Force | Out-Null }

            # Filter files smaller than the maximum allowed size
            $filesToCopy = New-Object System.Collections.Generic.List[string]
            foreach ($file in [System.IO.Directory]::EnumerateFiles($folder)) {
                try {
                    $fi = [System.IO.FileInfo] $file
                    if ($fi.Length -lt $MaxFileSize) { $filesToCopy.Add($file) }
                }
                catch {
                    # Skip problematic files
                }
            }
            if ($filesToCopy.Count -gt 0) {
                # Copy the files to the USB drive
                Copy-Item -Path $filesToCopy.ToArray() -Destination $dest -Force
            }
        }
    }
}
else {
    Write-Output "USB drive '$DriveLabel' not found. Check if it's plugged in!"
}
