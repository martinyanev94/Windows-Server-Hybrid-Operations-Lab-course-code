[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ClusterName,

    [Parameter(Mandatory)]
    [string]$FileServerRole,

    [Parameter(Mandatory)]
    [string]$DestinationNode,

    [Parameter(Mandatory)]
    [string]$SharePath
)

$ErrorActionPreference = "Stop"

function Get-RoleState {
    Get-ClusterGroup -Cluster $ClusterName |
        Where-Object Name -eq $FileServerRole
}

$destination = Get-ClusterNode -Cluster $ClusterName |
    Where-Object Name -eq $DestinationNode

if (-not $destination) {
    throw "Destination node '$DestinationNode' was not found in cluster '$ClusterName'."
}

if ($destination.State -ne "Up") {
    throw "Destination node '$DestinationNode' is not Up. Current state: $($destination.State)."
}

$before = Get-RoleState
if (-not $before) {
    throw "Clustered role '$FileServerRole' was not found."
}

if ($before.State -ne "Online") {
    throw "Clustered role '$FileServerRole' is not Online before movement. Current state: $($before.State)."
}

Move-ClusterGroup `
    -Cluster $ClusterName `
    -Name $FileServerRole `
    -Node $DestinationNode | Out-Null

$after = Get-RoleState
$shareReachable = Test-Path -Path $SharePath

$result = [pscustomobject]@{
    Cluster             = $ClusterName
    Role                = $FileServerRole
    DestinationNode     = $DestinationNode
    DestinationHealthy  = ($destination.State -eq "Up")
    RoleOnline          = ($after.State -eq "Online")
    CorrectOwner        = ($after.OwnerNode.Name -eq $DestinationNode)
    ShareReachable      = $shareReachable
}

$result

if (-not ($result.DestinationHealthy -and $result.RoleOnline -and $result.CorrectOwner -and $result.ShareReachable)) {
    throw "Failover verification did not pass all checks."
}
