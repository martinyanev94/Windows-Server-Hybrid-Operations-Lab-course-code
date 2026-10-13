# Domain-controller validation

This PowerShell check records evidence for the lesson's password-spraying scenario. It does not change domain-controller settings.

## Run

From an administrative PowerShell session on a lab management workstation:

```powershell
.\verify-domain-controller.ps1 -DomainController DC01 -ApprovedAdminWorkstation SAW01
.\verify-domain-controller.ps1 -DomainController DC01 -ApprovedAdminWorkstation SAW01 -AlertOwnerAssigned:$false
```

Use a reachable lab controller name and do not place credentials or tokens in this file. The first run should produce `Review` only when management is reachable, the sensor state is `Healthy`, a suspicious identity signal is present, and an alert owner is assigned. The second command demonstrates the missing-owner case and should produce `Investigate` when the controller evidence is otherwise reviewable.
