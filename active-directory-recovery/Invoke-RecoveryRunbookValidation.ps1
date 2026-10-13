param(
    [string]$Path = './ad-recovery-runbook.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runbook = Get-Content -Path $Path -Raw | ConvertFrom-Json
$required = @(
    'Capture evidence',
    'Enter DSRM',
    'Recover AD database',
    'Validate directory',
    'Recover SYSVOL',
    'Validate SYSVOL'
)
$actual = @($runbook.steps.name)

if ($actual.Count -ne $required.Count) {
    throw "Expected exactly $($required.Count) checkpoints. Found $($actual.Count)."
}

for ($i = 0; $i -lt $required.Count; $i++) {
    if ($actual[$i] -ne $required[$i]) {
        throw "Checkpoint $($i + 1) must be '$($required[$i])'."
    }
}

foreach ($step in $runbook.steps) {
    if ([string]::IsNullOrWhiteSpace($step.validation)) {
        throw "Checkpoint '$($step.name)' has no validation statement."
    }
}

foreach ($name in @('Recover AD database', 'Recover SYSVOL')) {
    $step = $runbook.steps | Where-Object { $_.name -eq $name }
    if (-not $step.stop_if_failed) {
        throw "Checkpoint '$name' must stop when validation fails."
    }
}

'Runbook order and stop conditions are valid.'
