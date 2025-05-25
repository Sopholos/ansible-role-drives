#!/snap/bin/powershell -Command
# Ansible managed
param(
    [parameter(Mandatory=$true)][string]$sourceDir,
    [parameter(Mandatory=$true)][string]$s3Bucket,
    [parameter(Mandatory=$false)][string]$s3Folder,
    [parameter(Mandatory=$false)][string]$s3Prefix,
    [parameter(Mandatory=$true)][string]$s3Endpoint,
    [parameter(Mandatory=$true)][string]$s3Profile,
    [parameter(Mandatory=$false)][bool]$s3Delete = $false,
    [parameter(Mandatory=$false)][string[]]$s3Exclude = @()
)

$ErrorActionPreference = "Stop"

$start = Get-Date

try {
    $s3Path = "s3://$s3Bucket/"
    if ($s3Prefix) {
        $s3Path += "$s3Prefix/"
    }
    if ($s3Folder) {
        $s3Path += "$s3Folder/"
    }
    Write-Output "Syncing $sourceDir to S3: $s3Path"

    $awsArgs = @(
        "--profile", $s3Profile,
        "--endpoint-url", $s3Endpoint,
        "s3", "sync",
        $sourceDir,
        $s3Path
    )

    if ($s3Delete) {
        $awsArgs += "--delete"
    }

    foreach ($excludePattern in $s3Exclude) {
        if ($excludePattern) {
            $awsArgs += "--exclude"
            $awsArgs += $excludePattern
        }
    }

    aws @awsArgs
    if ($LASTEXITCODE -ne 0) { throw "aws s3 sync exited with code $LASTEXITCODE." }

    Write-Host "Synced successfully to S3" -ForegroundColor Green
}
finally {
    Write-Host "Took: " ((Get-Date) - $start)
}