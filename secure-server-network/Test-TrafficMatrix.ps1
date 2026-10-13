[CmdletBinding()]
param(
    [string]$Path = "$PSScriptRoot/traffic-matrix.json"
)

Set-StrictMode -Version Latest
$matrix = Get-Content -Raw -Path $Path | ConvertFrom-Json

$requiredBoundaries = @('connection-security', 'storage-firewall')
foreach ($boundary in $requiredBoundaries) {
    if (-not ($matrix.rules.boundary -contains $boundary)) {
        throw "Missing required boundary: $boundary"
    }
}

foreach ($rule in $matrix.rules) {
    if ([string]::IsNullOrWhiteSpace($rule.name) -or
        [string]::IsNullOrWhiteSpace($rule.destination) -or
        $rule.action -ne 'Allow') {
        throw "Invalid rule: $($rule.name)"
    }
}

$allowed = @($matrix.expectedResults | Where-Object { $_.expected -like 'Allowed*' })
$denied = @($matrix.expectedResults | Where-Object { $_.expected -like 'Denied*' })

[pscustomobject]@{
    RulesChecked = @($matrix.rules).Count
    AllowedCases = $allowed.Count
    DeniedCases = $denied.Count
    Status = 'Matrix structure is valid; perform live path tests separately.'
}
