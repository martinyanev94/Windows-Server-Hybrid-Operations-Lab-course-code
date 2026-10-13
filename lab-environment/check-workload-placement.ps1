Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$planPath = Join-Path $PSScriptRoot 'workload-placement.json'
$plan = Get-Content $planPath -Raw | ConvertFrom-Json
$allowedModels = 'on-premises', 'hybrid', 'cloud-native'

if (-not $plan.workloads -or $plan.workloads.Count -ne 3) {
    throw 'Expected exactly three workload placement records.'
}

foreach ($workload in $plan.workloads) {
    if ([string]::IsNullOrWhiteSpace($workload.name)) {
        throw 'Every workload must have a name.'
    }

    if ($workload.model -notin $allowedModels) {
        throw "Unknown model '$($workload.model)' for '$($workload.name)'."
    }

    if ([string]::IsNullOrWhiteSpace($workload.reason)) {
        throw "Missing operational reason for '$($workload.name)'."
    }

    '{0}: {1} — {2}' -f $workload.name, $workload.model, $workload.reason
}

'Placement plan is valid.'
