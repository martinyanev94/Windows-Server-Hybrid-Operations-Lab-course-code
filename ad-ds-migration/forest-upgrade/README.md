# Forest upgrade readiness validator

This small Python validator checks the structure of the illustrative forest-upgrade plan used in lesson l30. It does not connect to Active Directory and does not prove live replication, compatibility, or directory health.

Run from this directory:

```text
python3 validate_plan.py sample-plan.json
```

A `READY` result means the plan contains the required ordered gates and post-change checks. Live Windows validation still requires the documented PowerShell checks and an approved maintenance window.
