#!/snap/bin/powershell -Command
# Ansible managed
param(
    [parameter(Mandatory=$true)][string]$sourceVG,
    [parameter(Mandatory=$true)][string]$sourceLV,

    [parameter(Mandatory=$true)][string]$snapshotSize,
	[parameter(Mandatory=$true)][string]$snapshotVL,
    [parameter(Mandatory=$true)][string]$mountPoint,

    [parameter(Mandatory=$false)][bool]$isXFS = $False
)

$ErrorActionPreference = "Stop"

Write-Output "Creating snapshot..."
# xfs_freeze -f $mountPoint ### ??? http://www.opennet.ru/docs/HOWTO/LVM-HOWTO/snapshots_backup.html
lvcreate `
    --snapshot `
    --size $snapshotSize `
    --name $snapshotVL `
    $sourceVG/$sourceLV
# xfs_freeze -u $mountPoint

if ($LASTEXITCODE -ne 0) { throw "lvcreate exited with code $LASTEXITCODE." }

New-Item -ItemType Directory -Force -Path $mountPoint

Write-Output "Mounting snapshot..."
if ($isXFS) {
    &mount /dev/mapper/$sourceVG-$snapshotVL $mountPoint -o nouuid,ro # options to xfs
}
else {
    &mount /dev/mapper/$sourceVG-$snapshotVL $mountPoint
}

if ($LASTEXITCODE -ne 0) { throw "mount exited with code $LASTEXITCODE." }