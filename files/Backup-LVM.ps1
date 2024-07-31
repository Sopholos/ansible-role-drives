#!/snap/bin/powershell -Command
# Ansible managed
param(
    [parameter(Mandatory=$true)][hashtable[]]$source,
    [parameter(Mandatory=$true)][string]$destination,

    [parameter(Mandatory=$true)][string]$snapshotSize,

    [parameter(Mandatory=$false)][bool]$isXFS = $False,
    [Parameter(Mandatory=$false)][ValidateSet("BackupTar", "Backup7z")][string]$backupType = "BackupTar"
)

$ErrorActionPreference = "Stop"

$start = Get-Date

$scriptDir = Split-Path $PSCommandPath

try {
    try {
        $sourceFiltered = $source | Where-Object { $_.vg -ne $null }

        foreach ($source_lvm in $sourceFiltered) {
            & $scriptDir/Create-LVMSnapshot.ps1 `
                -sourceVG $source_lvm.vg `
                -sourceLV $source_lvm.lv `
                -snapshotSize $snapshotSize `
                -snapshotVL $source_lvm.snapshotVL `
                -mountPoint $source_lvm.mountPoint `
                -isXFS $isXFS
        }

        foreach ($source_lvm in $sourceFiltered) {
            if ($source_lvm.backup -eq 1) {
                $dest = "$($destination)_$($source_lvm.snapshotVL)"
                & $scriptDir/Backup-Folder.ps1 `
                    -backupType $backupType `
                    -source $source_lvm.mountPoint `
                    -destination $dest
            }
        }

        Write-Host "Backed up whole group sucesfully" -ForegroundColor Green
    }
    finally {
        foreach ($source_lvm in $sourceFiltered) {
            try {
                & $scriptDir/Drop-LVMSnapshot.ps1 `
                    -sourceVG $source_lvm.vg `
                    -snapshotVL $source_lvm.snapshotVL `
                    -mountPoint $source_lvm.mountPoint
            }
            catch {
                Write-Host "Snapshot cleanup $hostName error: $_" -ForegroundColor Yellow
            }
        }
    }
}
finally {
    Write-Host "Took: " ((Get-Date) - $start)
}
