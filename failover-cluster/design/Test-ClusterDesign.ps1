param(
    [string]$Path = (Join-Path $PSScriptRoot 'cluster-design.json')
)

$design = Get-Content $Path -Raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()

if ($design.nodes.Count -lt 2) {
    $errors.Add('At least two nodes are required')
}
if (-not $design.witness.type) {
    $errors.Add('A quorum witness is required')
}
if (-not $design.witness.storageAccount -or -not $design.witness.serviceEndpoint) {
    $errors.Add('Cloud witness target is incomplete')
}
if ($design.networks.Count -lt 2) {
    $errors.Add('At least two cluster networks are required')
}
if ($design.sharedStorage.Count -eq 0) {
    $errors.Add('At least one shared storage resource is required')
}
foreach ($role in $design.roles) {
    if ($design.sharedStorage -notcontains $role.storage) {
        $errors.Add("Role $($role.name) references undeclared storage")
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { "FAIL: $_" }
    exit 1
}

if ($design.witness.credentialsPending -eq $true) {
    'PENDING: Cloud Witness credentials must be supplied and reachability tested'
    exit 2
}

'PASS: design is internally consistent and witness credentials are not pending'
"Nodes: $($design.nodes.Count)"
"Witness: $($design.witness.type) / $($design.witness.storageAccount) / $($design.witness.serviceEndpoint)"
"Networks: $($design.networks.Count)"
"Shared storage: $($design.sharedStorage -join ', ')"
