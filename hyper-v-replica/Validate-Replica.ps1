param(
    [Parameter(Mandatory)]
    [string]$VMName,
    [switch]$FailIfUnhealthy
)

$ErrorActionPreference = 'Stop'

$replication = Get-VMReplication -VMName $VMName
$health = Measure-VMReplicationHealth -VMName $VMName

$record = [pscustomobject]@{
    VMName = $VMName
    ReplicationState = $replication.State
    ReplicationMode = $replication.Mode
    LastReplicationTime = $replication.LastReplicationTime
    Health = $health.Health
    HealthDescription = $health.HealthDescription
    CheckedAt = Get-Date
}

$record | Format-List

if ($FailIfUnhealthy -and $health.Health -ne 'Normal') {
    throw "Replication health for $VMName is $($health.Health): $($health.HealthDescription)"
}
