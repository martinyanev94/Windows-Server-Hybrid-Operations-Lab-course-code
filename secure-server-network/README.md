# Secure server network traffic matrix

This project models the lesson's three firewall-stack decisions.

## Run

From PowerShell, run:

```powershell
.\Test-TrafficMatrix.ps1
```

The script predicts the Azure NSG match first, then the Windows Defender Firewall host match. It is a deterministic model for the documented inputs; validate a live environment separately with effective NSG inspection, effective firewall rules, and a connection test.
