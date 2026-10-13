[CmdletBinding()]
param(
    [string]$Path = (Join-Path $PSScriptRoot 'recovery-plan.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$plan = Get-Content -Path $Path -Raw | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($plan.networkMappings.'Production-Server-Network'.failover)) {
    throw 'Missing failover network mapping.'
}
if ([string]::IsNullOrWhiteSpace($plan.networkMappings.'Production-Server-Network'.testFailover)) {
    throw 'Missing test-failover network mapping.'
}
if ($plan.replicationPolicy.rpoMinutes -le 0) {
    throw 'RPO must be greater than zero.'
}
if ($plan.replicationPolicy.retentionHours -le 0) {
    throw 'Retention must be greater than zero.'
}

$seenGroups = @{}
$seenWorkloads = @{}
$previousOrder = 0
foreach ($group in ($plan.groups | Sort-Object order)) {
    if ($group.order -le $previousOrder) {
        throw "Group order is not strictly increasing at $($group.name)."
    }
    $previousOrder = $group.order
    foreach ($dependency in @($group.dependsOn)) {
        if (-not $seenGroups.ContainsKey($dependency)) {
            throw "Dependency $dependency must precede $($group.name)."
        }
    }
    foreach ($workload in @($group.workloads)) {
        if ($seenWorkloads.ContainsKey($workload)) {
            throw "Workload $workload appears more than once."
        }
        $seenWorkloads[$workload] = $group.name
    }
    $seenGroups[$group.name] = $true
}
'Recoverability design is structurally valid.'
