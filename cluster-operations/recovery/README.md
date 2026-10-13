# Cluster recovery validation

This runbook validates a recovered node and optionally performs a controlled move of one clustered role.

## Preconditions

- Run from a functioning cluster node with the Failover Clustering PowerShell tools installed.
- Confirm the failed node's workload has moved to another available node before eviction or rebuild.
- Repair or rebuild the failed node and rejoin it to the existing cluster before using `-MoveRole`.
- Use an approved clustered role name and destination node.

## Read-only validation

```powershell
.\Invoke-RecoveryValidation.ps1 `
  -RoleName 'FILE-SHARE' `
  -RecoveredNode 'NODE-A' `
  -ExpectedOwner 'NODE-B'
```

This verifies that the recovered node is Up, the role is Online, and the current owner matches the expected owner. It does not move the role.

## Controlled failback

After the node is healthy and the client path has been checked, perform the intended move explicitly:

```powershell
.\Invoke-RecoveryValidation.ps1 `
  -RoleName 'FILE-SHARE' `
  -RecoveredNode 'NODE-A' `
  -ExpectedOwner 'NODE-A' `
  -MoveRole
```

The script reports node state, role state, expected owner, actual owner, and whether ownership matches. Validate the client-facing clustered name separately; an Online role and correct owner do not by themselves prove client access.
