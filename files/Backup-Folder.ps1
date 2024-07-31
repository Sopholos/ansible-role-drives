#!/snap/bin/powershell -Command
# Ansible managed
param(
    [parameter(Mandatory=$true)][string]$source,
    [parameter(Mandatory=$true)][string]$destination,
    [Parameter(Mandatory=$false)][ValidateSet("BackupTar", "Backup7z")][string]$backupType = "BackupTar",
    [parameter(Mandatory=$false)][bool]$doneFlag = $true
)

$ErrorActionPreference = "Stop"

$start = Get-Date

try {
    enum BackupType {
        BackupTar
        Backup7z
    }

    [BackupType]$bType = $backupType

    $destinationFile = switch ( $bType )
    {
        BackupTar { "$destination.tar" }
        Backup7z { "$destination.7zbk" }
        default {  throw "Unknown backupType $bType" }
    }

    Write-Output "Backing up $source to $destinationFile"

    switch ($bType)
    {
        BackupTar {
            tar -cf $destinationFile $source
            if ($LASTEXITCODE -ne 0) { throw "tar exited with code $LASTEXITCODE." }
        }
        Backup7z {
            7z a -mmt=2 $destinationFile $source
            if ($LASTEXITCODE -ne 0) { throw "7z exited with code $LASTEXITCODE." }
        }
        default {
            throw "Unknown backupType $bType"
        }
    }

    if ($doneFlag) {
        $doneFile = "$destinationFile.done"
        $(Get-Date -format "yyyy-MM-dd HH:mm:ss") | Set-Content $doneFile
    }

    Write-Host "Backed up sucesfully $source to $destinationFile" -ForegroundColor Green
}
finally{
    Write-Host "Took: " ((Get-Date) - $start)
}