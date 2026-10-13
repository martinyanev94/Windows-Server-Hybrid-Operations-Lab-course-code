# Clustered workload failover

This example moves an existing clustered file-server role to a healthy node and verifies the client-facing share path.

The cluster, shared storage, clustered role, and SMB share must already exist. Use the approved design from the previous lesson. Do not place credentials or recovery secrets in this file or on the command line.

## Run

Open an elevated PowerShell session with the Failover Clustering tools available, then run:

```powershell
.\Invoke-WorkloadFailover.ps1 `
  -ClusterName "LAB-CLUSTER" `
  -FileServerRole "FS-CLUSTER" `
  -DestinationNode "NODE-B" `
  -SharePath "\\FS-CLUSTER\TeamShare"
```

The script checks that the destination node is Up, confirms that the role is Online before movement, moves the role, and then verifies:

- the destination node is Up;
- the clustered role is Online;
- the role owner is the requested destination node; and
- the client-facing share path is reachable.

A successful command is not sufficient evidence by itself. Record the returned object with the owner and share results as the failover evidence. If a check fails, investigate the failed layer before attempting another move.
