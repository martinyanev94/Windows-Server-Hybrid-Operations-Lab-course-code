# IIS Role Migration Checklist

## Workload

- [ ] Record source server and destination server.
- [ ] Record site names: AZ801-App1, AZ801-App2, AZ801-App3.
- [ ] Record each site's application type, owner, and criticality.
- [ ] Record the rollback owner and cutover window.

## Discovery and dependencies

- [ ] Record bindings, host names, ports, and certificates for each site.
- [ ] Record application pool names, identities, runtime settings, and restart behavior.
- [ ] Record content paths and required file permissions.
- [ ] Record databases, APIs, services, and other external dependencies.
- [ ] Run dependency inspection for each site; for example:
      msdeploy -verb:getDependencies -source:apphostConfig="AZ801-App1"
- [ ] Save the dependency output with the migration record.

## Destination preparation

- [ ] Install the required IIS features and compatible application components.
- [ ] Create compatible application pools and identities.
- [ ] Prepare content paths and permissions.
- [ ] Import required certificates through the approved secure process.
- [ ] Prepare access to databases and dependent services.

## Transfer and coexistence

- [ ] Transfer site configuration and content with the approved Web Deploy method.
- [ ] Keep the source available during acceptance testing.
- [ ] Confirm destination bindings and application-pool state.
- [ ] Record source and destination comparison evidence.

## Acceptance gate

- [ ] Test each site through its intended host name or approved test path.
- [ ] Verify expected page or application behavior.
- [ ] Verify dependent database or service access.
- [ ] Verify certificate and binding behavior.
- [ ] Verify relevant logs contain no migration-blocking errors.
- [ ] Record observed results for every site.

## Cutover and rollback

- [ ] Cut over traffic only after every required acceptance check passes.
- [ ] Keep the source available through the agreed rollback period.
- [ ] If a required client-path or dependency check fails, return traffic to the source.
- [ ] Preserve destination evidence and document the failed check.
- [ ] Decommission the source only after the rollback period and owner approval.
