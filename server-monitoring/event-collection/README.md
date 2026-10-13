# Event collection investigation

This artifact answers a bounded question against a local Windows event log:
which events were recorded in a named channel during a specified time window?

## Run

Open PowerShell with permission to read the selected log, then run:

```powershell
.\Find-Events.ps1 `
  -LogName Security `
  -StartTime '2026-10-12 09:00' `
  -EndTime '2026-10-12 10:00' `
  -OutputPath .\migration-events.csv
```

The script returns timestamp, event ID, provider, level, and message. An empty
result means that this query found no matching events; it does not prove that
the server or collection path was healthy.

## Azure Monitor mapping

Configure the corresponding Azure Monitor Data Collection Rule with a Windows
event-log data source for the channel required by the operational question.
Associate the rule with the monitored server. Azure VMs use the VM extension
installation path. Non-Azure servers require Azure Arc before Azure Monitor
Agent collection can be configured.

Keep the channel, server, and time window in the investigation record so the
local result and centralized query answer the same question.
