# Storage Spaces Direct design artifact

This project validates the documented S2D design before live infrastructure work.

## Run

From PowerShell:

```powershell
./Test-S2DPlan.ps1
```

The validator checks the illustrative three-node plan for deployment mode, one storage pool, the documented 10 Gbps network baseline, redundant connections, clean drives, and a complete one-node-at-a-time upgrade order.

The values are planning inputs, not proof that live hardware, storage, firmware, cluster health, or workload access has been validated. Confirm those conditions separately before enabling S2D or upgrading a node.
