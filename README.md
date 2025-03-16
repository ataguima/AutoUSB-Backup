# Backup Script for USB Drive

This PowerShell script quickly backs up files from selected user folders to a USB drive based on its label. It only transfers files smaller than 10MB, ensuring a fast operation. The process is optimized to allow the user to insert the USB drive, perform the backup, and eject it within seconds — ideal for quick, on-the-go "backups".

## Features

The script performs the following actions:
- Detects a USB drive with the specified label.
- Creates a folder structure on the USB drive if it doesn't exist.
- Copies files from selected folders (Downloads, Documents, etc.) to the USB drive, ignoring files larger than 10MB.

## Parameters

- **DriveLabel** (string): The label of the USB drive. Default is `'DRIVEUPDATE'`.
- **SourceFolders** (array[string]): A list of source folders to copy from. Defaults to `Downloads`, `Documents`, `Pictures`, `Videos`, and Chrome data.
- **DestinationSubfolder** (string): The name of the subfolder on the USB drive where the files will be stored. Default is `'Data'`.
- **MaxFileSize** (long): The maximum file size to copy, in bytes. Default is 10MB.

## Example Usage

```powershell
.\backup-script.ps1 -DriveLabel "MY_DRIVE" -SourceFolders "$env:USERPROFILE\Documents" -DestinationSubfolder "Backup" -MaxFileSize 10485760
