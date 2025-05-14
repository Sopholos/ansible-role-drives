#!/snap/bin/powershell -Command
# Ansible managed
param(
    [parameter(Mandatory=$true)][string]$sourceDir,
    [parameter(Mandatory=$true)][string]$s3Bucket,
    [parameter(Mandatory=$true)][string]$s3Folder,
    [parameter(Mandatory=$true)][string]$s3Prefix,
    [parameter(Mandatory=$true)][string]$s3Endpoint,
    [parameter(Mandatory=$true)][string]$s3Profile,
    [parameter(Mandatory=$false)][bool]$s3Delete = $false
)

$ErrorActionPreference = "Stop"

$start = Get-Date

try {
    $s3Path = "s3://$s3Bucket/$s3Prefix/$s3Folder/"
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

    aws @awsArgs
    if ($LASTEXITCODE -ne 0) { throw "aws s3 sync exited with code $LASTEXITCODE." }

    Write-Host "Synced successfully to S3" -ForegroundColor Green
}
finally {
    Write-Host "Took: " ((Get-Date) - $start)
}