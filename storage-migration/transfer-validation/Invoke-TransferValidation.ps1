param(
    [Parameter(Mandatory)] [string] $SourceInventory,
    [Parameter(Mandatory)] [string] $TargetInventory,
    [string] $ReportPath = 'transfer-validation-report.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-Inventory([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Inventory file not found: $Path"
    }
    Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Normalize-List($Value) {
    @($Value | ForEach-Object { [string] $_ } | Sort-Object)
}

$source = Read-Inventory $SourceInventory
$target = Read-Inventory $TargetInventory

$checks = @(
    [pscustomobject]@{ Name='ShareName'; Pass=[string]$source.shareName -eq [string]$target.shareName; Source=[string]$source.shareName; Target=[string]$target.shareName }
    [pscustomobject]@{ Name='LocalPath'; Pass=[string]$source.localPath -eq [string]$target.localPath; Source=[string]$source.localPath; Target=[string]$target.localPath }
    [pscustomobject]@{ Name='Files'; Pass=(Normalize-List $source.files) -join '|' -eq (Normalize-List $target.files) -join '|'; Source=(Normalize-List $source.files) -join '; '; Target=(Normalize-List $target.files) -join '; ' }
    [pscustomobject]@{ Name='Permissions'; Pass=(Normalize-List $source.permissions) -join '|' -eq (Normalize-List $target.permissions) -join '|'; Source=(Normalize-List $source.permissions) -join '; '; Target=(Normalize-List $target.permissions) -join '; ' }
    [pscustomobject]@{ Name='Dependencies'; Pass=(Normalize-List $source.dependencies) -join '|' -eq (Normalize-List $target.dependencies) -join '|'; Source=(Normalize-List $source.dependencies) -join '; '; Target=(Normalize-List $target.dependencies) -join '; ' }
)

$report = [pscustomobject]@{
    source = $SourceInventory
    target = $TargetInventory
    passed = @($checks | Where-Object Pass).Count
    failed = @($checks | Where-Object { -not $_.Pass }).Count
    checks = $checks
}

$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ReportPath -Encoding utf8
$checks | Format-Table Name, Pass, Source, Target -AutoSize

if ($report.failed -gt 0) {
    exit 1
}

exit 0
