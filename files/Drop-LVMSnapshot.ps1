#!/snap/bin/powershell -Command
# Ansible managed
param(
    [parameter(Mandatory=$true)][string]$sourceVG,
    [parameter(Mandatory=$true)][string]$snapshotVL,
    [parameter(Mandatory=$true)][string]$mountPoint
)

$ErrorActionPreference = "Stop"

try {
    Write-Output "Unmounting snapshot..."
    umount $mountPoint

    if ($LASTEXITCODE -ne 0) { throw "umount exited with code $LASTEXITCODE." }
}
finally {
    Write-Output "Removing snapshot..."
    lvremove --yes /dev/$sourceVG/$snapshotVL #--force

    if ($LASTEXITCODE -ne 0) { throw "lvremove exited with code $LASTEXITCODE." }
}
