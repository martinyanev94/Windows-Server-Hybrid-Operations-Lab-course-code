# Delegation matrix

This artifact records the intended boundary for a helpdesk password-reset role.
It does not modify Active Directory. Apply the delegation through the Delegation
of Control Wizard or an approved automation process, then use the review questions
as evidence requirements.

## Run

From PowerShell:

```powershell
.\delegation-matrix.ps1 | Set-Content .\delegation-matrix.json
```

The example uses placeholder distinguished names and does not contain credentials.
Replace the target OU only with an approved lab or production scope. Verify both
an allowed password reset and a denied privileged-group modification. Record the
operator account, target object, operation, result, and timestamp in the change
record.

## Intended boundary

- Role group: `Helpdesk-PasswordReset`
- Scope: `OU=Helpdesk Users,DC=corp,DC=example`
- Allowed: reset password, force password change, unlock account
- Denied: create users, modify group membership, write permissions, administer domain controllers
