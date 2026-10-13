# Active Directory recovery validation

This project records the on-premises evidence needed before declaring a repaired AD and hybrid sign-in dependency chain healthy.

## Run on an authorized domain-controller administration host

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Invoke-ReplicationAuthValidation.ps1 -DomainController DC01 -EvidenceDirectory .\evidence
```

The script captures:

- `repadmin /replsummary` for replication-summary evidence.
- `repadmin /showrepl` for the selected controller's partner and naming-context evidence.
- Targeted `dcdiag` checks for replication, SYSVOL, role advertising, and DNS.

Use `-SkipLiveCommands` to generate the report structure without contacting domain controllers. A skipped or captured command is not a health assertion.

After the on-premises checks, correlate the affected identity with the synchronization service result and the matching cloud sign-in record. Record those results separately; this script does not perform synchronization or cloud operations.

Do not place passwords, recovery keys, tokens, or other secrets in the evidence directory. The report is a structure-validation aid, not a substitute for environment-specific recovery approval or live health analysis.
