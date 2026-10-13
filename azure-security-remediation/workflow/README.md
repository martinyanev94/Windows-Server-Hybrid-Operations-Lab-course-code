# Finding workflow

This PowerShell example tracks F-104 from assignment through remediation and evidence-based closure.

Run it on Windows PowerShell 5.1 or PowerShell 7:

```powershell
pwsh ./Invoke-FindingWorkflow.ps1
```

Expected teaching result:

- Finding: F-104
- Target: AZ801Lab-FS-01
- Owner: Windows platform team
- Status: Closed
- Verification: Fresh assessment: F-104 resolved on AZ801Lab-FS-01

The sample uses illustrative data. In a real environment, replace the evidence and structured verification result with evidence from the connected monitoring and security services. A verification result with resolved set to false remains Remediated rather than becoming Closed.
