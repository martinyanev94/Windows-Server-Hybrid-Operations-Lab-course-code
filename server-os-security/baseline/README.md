# Windows Server baseline

Run `Invoke-Baseline.ps1` from an elevated PowerShell session on the disposable lab server.

The script preserves the initial local security policy, applies a small baseline, refreshes computer policy, exports effective state, and writes `verification.json`.

Expected lab values:

- Minimum password length: 14
- Password complexity: enabled (`1`)
- Lockout bad attempts: 5
- PowerShell script block logging: enabled (`1`)
- Security log maximum size: 196,608 bytes

A domain-linked Group Policy Object may override local settings. Preserve that difference as an exception and investigate policy precedence; do not edit the verification output to conceal it.
