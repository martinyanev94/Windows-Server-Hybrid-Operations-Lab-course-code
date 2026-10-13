# Performance baseline

Run the focused Windows performance sample against vm-app01:

```powershell
.\Invoke-PerformanceBaseline.ps1 -OutputPath .\vm-app01-counters.csv
```

The script records processor time, available memory, disk transfer latency, and network throughput. Compare its output with an incident window before deciding that the VM is resource-constrained.

For Azure collection, associate vm-app01 with an Azure Monitor Data Collection Rule that includes the required counters, then verify recent records in the Log Analytics workspace with a scoped Perf query.
