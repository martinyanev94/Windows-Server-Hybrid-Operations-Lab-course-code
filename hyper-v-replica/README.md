# Hyper-V Replica validation

This small PowerShell utility inspects an existing Hyper-V Replica relationship. It does not enable replication or perform failover.

## Usage

Run on a Hyper-V host with the Hyper-V PowerShell module and appropriate administrative rights:

```powershell
.\Validate-Replica.ps1 -VMName APP01
.\Validate-Replica.ps1 -VMName APP01 -FailIfUnhealthy
```

The second command exits with an error when the reported health is not `Normal`. Treat that output as evidence about the replication relationship only; it does not prove that a recovered application is reachable. Validate the VM, network isolation or routing, and application endpoint separately during a test failover.
