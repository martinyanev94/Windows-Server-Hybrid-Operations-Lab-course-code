# Cluster maintenance runbook

## Scope

Update `NODE-A` and `NODE-B` one node at a time while keeping the clustered file-server role available through its stable role identity.

## Starting state

- Quorum is established.
- `NODE-A` owns the clustered file-server role.
- `NODE-B` is healthy and available as the failover destination.
- The clustered share is reachable through the role identity.

## Prechecks

1. Confirm quorum is established.
2. Confirm the Cluster service is running on both nodes.
3. Confirm both nodes are in the same domain and the cluster name resolves in DNS.
4. Confirm the update account has the required local administrative permissions.
5. Confirm remote management, PowerShell remoting, and required firewall rules work.
6. Confirm the file-server role is online and currently owned by `NODE-A`.
7. Read a test file through the clustered share using the role identity.

Stop the run if any precheck fails.

## Update sequence

### 1. Maintain NODE-A

1. Drain `NODE-A` and place it into maintenance.
2. Confirm the file-server role is online on `NODE-B`.
3. Read the test file through the clustered share.
4. Install the approved updates on `NODE-A`.
5. Allow the required restart to complete.
6. Confirm `NODE-A` is healthy and has resumed active cluster participation.

Stop the run if the role is not online on `NODE-B`, the share cannot be read, or `NODE-A` does not return healthy.

### 2. Maintain NODE-B

1. Drain `NODE-B` and place it into maintenance.
2. Confirm the file-server role is online on `NODE-A`.
3. Read the test file through the clustered share.
4. Install the approved updates on `NODE-B`.
5. Allow the required restart to complete.
6. Confirm `NODE-B` is healthy and has resumed active cluster participation.

Stop the run if the role is not online on `NODE-A`, the share cannot be read, or `NODE-B` does not return healthy.

## Postchecks

- Both nodes are online and healthy.
- The Cluster service is running on both nodes.
- The clustered file-server role is online.
- The role is reachable through its stable client identity.
- A test file can be read through the clustered share.
- The update run reports completion and no unresolved node or role errors.

## Decision rule

Never update the node that currently owns the workload until a healthy destination node has accepted the role and the client path has been verified. Never start the next node's maintenance until the previous node has returned healthy and resumed cluster participation.
