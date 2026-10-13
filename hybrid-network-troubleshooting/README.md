# Hybrid connectivity incident check

This PowerShell utility records a bounded connectivity observation in four layers:

1. DNS resolution and comparison with an expected address.
2. The local route selected for the resolved address.
3. TCP connectivity to the requested port.
4. Local firewall-profile evidence, explicitly marked as requiring policy review.

Example invocation from an approved Windows test server:

```powershell
.\Invoke-HybridConnectivityCheck.ps1 `
  -TargetName 'app01.contoso.test' `
  -ExpectedAddress '10.20.4.15' `
  -Port 443 `
  -OutputPath '.\connectivity-incident.json'
```

The script does not claim that local firewall profiles prove Azure NSG, VPN, or remote-host policy. Attach matching Azure Network Watcher or VPN diagnostic evidence to the generated incident record when the failing path crosses Azure.

The hostname, address, and port above are illustrative values. Replace them only with approved lab or production test values, and do not store credentials or secrets in the report.
