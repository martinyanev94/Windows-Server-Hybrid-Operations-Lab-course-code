# Azure Site Recovery plan design

This project records a local recovery-plan design before it is configured in Azure Site Recovery.

The recovery point, policy values, target networks, and validation checks are illustrative inputs for the lesson and must be confirmed with the workload owner and deployment evidence.

The validator checks network mappings, positive policy values, group ordering, dependency ordering, and duplicate workloads. It does not prove replication, routing, DNS, firewall access, or application health.

Run with PowerShell:

```powershell
./Validate-RecoveryPlan.ps1
```
