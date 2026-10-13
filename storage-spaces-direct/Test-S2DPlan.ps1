param(
    [string]$PlanPath = (Join-Path $PSScriptRoot 's2d-plan.json')
)

$plan = Get-Content $PlanPath -Raw | ConvertFrom-Json
$errors = @()

if ($plan.nodes.Count -lt 2) {
    $errors += 'At least two nodes are required.'
}

if ($plan.deploymentMode -notin @('hyper-converged', 'converged')) {
    $errors += 'Deployment mode must be hyper-converged or converged.'
}

if ($plan.storageLayout.poolCount -ne 1) {
    $errors += 'The plan must declare one storage pool per cluster.'
}

foreach ($node in $plan.nodes) {
    if ($node.networkGbps -lt 10) {
        $errors += "$($node.name): network is below 10 Gbps."
    }
    if ($node.connections -lt 2) {
        $errors += "$($node.name): fewer than two network connections are documented."
    }
    if (-not $node.drivesClean) {
        $errors += "$($node.name): drives are not documented as clean."
    }
}

$nodeNames = @($plan.nodes | ForEach-Object { $_.name })
if (@($plan.upgradeOrder).Count -ne $nodeNames.Count -or
    (@($plan.upgradeOrder | Sort-Object) -join ',') -ne (@($nodeNames | Sort-Object) -join ',')) {
    $errors += 'Upgrade order must contain each node exactly once.'
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { "FAIL: $_" }
    exit 1
}

'PASS: S2D design preflight is complete.'
