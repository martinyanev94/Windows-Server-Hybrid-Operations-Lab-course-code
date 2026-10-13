param(
    [Parameter(Mandatory)]
    [string]$RoleName,

    [Parameter(Mandatory)]
    [string]$RecoveredNode,

    [Parameter(Mandatory)]
    [string]$ExpectedOwner,

    [switch]$MoveRole
)

$ErrorActionPreference = 'Stop'

$node = Get-ClusterNode -Name $RecoveredNode
$role = Get-ClusterGroup -Name $RoleName

if ($node.State -ne 'Up') {
    throw "Recovered node '$RecoveredNode' is not Up. Current state: $($node.State)."
}

if ($MoveRole) {
    Move-ClusterGroup -Name $RoleName -Node $RecoveredNode -Wait 60 | Out-Null
    $role = Get-ClusterGroup -Name $RoleName
}

$actualOwner = $role.OwnerNode.Name

[pscustomobject]@{
    RecoveredNode = $RecoveredNode
    NodeState = $node.State
    RoleName = $RoleName
    RoleState = $role.State
    ExpectedOwner = $ExpectedOwner
    ActualOwner = $actualOwner
    OwnershipMatches = ($actualOwner -eq $ExpectedOwner)
} | Format-List

if ($role.State -ne 'Online') {
    throw "Cluster role '$RoleName' is not Online. Current state: $($role.State)."
}

if ($actualOwner -ne $ExpectedOwner) {
    throw "Cluster role '$RoleName' is owned by '$actualOwner', not '$ExpectedOwner'."
}
