# Lab environment topology

This project records the planned Hyper-V and Azure lab boundary before virtual machines are created.

## Validate the host

Run PowerShell as an administrator from this directory:

```powershell
.\check-topology.ps1
```

The script is read-only. It reports host information and processor virtualization capabilities; it does not change firmware, install Hyper-V, create switches, or create virtual machines.

## Review the result

Compare the report with `topology.json` and resolve missing prerequisites before continuing:

- Use a supported Windows edition or Windows Server platform.
- Confirm 64-bit processing, SLAT, and VM Monitor Mode Extension support.
- Confirm virtualization and hardware-enforced data execution prevention are enabled in firmware.
- Confirm enough memory is available for the host and planned guests.
- Record Azure tenant and subscription access without storing secrets.

The network names are logical design boundaries. Their purpose is recorded before physical or virtual switch configuration.
