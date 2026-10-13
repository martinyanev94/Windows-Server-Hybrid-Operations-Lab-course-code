# Utility-server migration checklist

## Selected workload
- Role: DHCP or print
- Source server:
- Destination server:
- Change window:
- Acceptance owner:

## Pre-migration evidence
- [ ] Source role and dependencies inventoried.
- [ ] Destination role and prerequisites verified.
- [ ] Source and destination IP configuration recorded.
- [ ] Migration store path is writable and protected.
- [ ] Source configuration export completed.
- [ ] Export result and event or migration logs retained.
- [ ] Source remains available for rollback.

## DHCP-specific acceptance
- [ ] Destination DHCP service remained stopped during import.
- [ ] DHCP settings and IP configuration imported.
- [ ] Destination service started and authorized.
- [ ] Test client renewed its lease.
- [ ] Assigned address, gateway, DNS, and lease source match expectations.
- [ ] Internal name resolution and service access succeeded.

## Print-specific acceptance
- [ ] Queues, ports, shares, and drivers exported.
- [ ] Destination import completed and reviewed.
- [ ] Representative client connected using the expected share name.
- [ ] Compatible driver installed or loaded.
- [ ] Permissions matched the approved access.
- [ ] Controlled test page printed successfully.

## Rollback gate
- Trigger:
- Recovery action:
- Client path used for re-test:
- Evidence captured:

## Closeout
- [ ] Acceptance owner approved the result.
- [ ] Source retained through the rollback period.
- [ ] Cleanup and decommissioning decision recorded separately from cutover.
