# ADR-013 — Database Role Architecture & Controlled Access Windows

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-011, ADR-012

## Decision

SWAFOS separates database/infrastructure authority from application business roles.

### Database roles

```text
bootstrap_owner
migration_role
application_runtime
readonly_reporting
background_worker
platform_operations
```

These are infrastructure/database identities, not tenant-facing application roles.

## Role Boundaries

### bootstrap_owner

Initial provisioning only. It creates the database roles and foundational privileges. It is not used by the application and must not be stored in application runtime configuration.

### migration_role

Used by controlled deployment/migration processes for schema changes. It is never used by the application runtime.

### application_runtime

Normal SWAFOS API/runtime database identity. It can execute authorized business transactions but does not receive schema-management privileges, SUPERUSER, or BYPASSRLS.

### readonly_reporting

Read-only identity for analytics/reporting workloads. It must not mutate transactional data. Reporting access should be abstracted so it can later move to a read replica without changing the reporting contract.

### background_worker

Controlled identity for scheduled/asynchronous jobs. V0.1 uses one worker role. Worker capabilities are scoped by application authorization and controlled database grants; future services may receive separate identities when isolation becomes valuable.

### platform_operations

Operational infrastructure authority, separate from tenant/business roles. It is not a normal application role and must not be exposed to tenants.

## No Permanent God Mode

No normal application or tenant database role receives unrestricted authority. In particular, application-facing roles must not receive:

- SUPERUSER;
- BYPASSRLS;
- schema ownership;
- unrestricted DDL;
- unrestricted cross-tenant access.

## Reporting Load Management

Reporting is designed for two stages.

### Stage V0.1

Reporting uses the primary database through a read-only path, with heavy scheduled reports executed during a configurable low-load window.

The scheduler should support:

- configurable local-time window;
- maximum concurrent reports;
- statement timeout;
- cancellation of overdue jobs;
- job priority;
- retry/backoff;
- observability of execution duration and database load.

Real-time operational dashboards should prefer lightweight queries and must not depend on the heavy reporting queue.

### Future Stage

When workload or data volume warrants it, reporting moves to a read replica:

```text
Primary
  ├── Application
  └── Replication
          ↓
      Read Replica
          ↓
   readonly_reporting
```

The application/reporting contract remains stable across the transition.

## Low-Load Window

A low-load window is an operational policy, not a security boundary.

The system must not assume that a particular clock hour is always safe. Before and during execution, scheduling/observability should account for actual load where practical.

Example configuration:

```text
reporting.window.start = 01:00
reporting.window.end   = 05:00
reporting.max_concurrency = 1
```

The exact production window is environment-specific and must be configurable.

## Emergency Platform Access

Platform emergency access for Awefit is break-glass and time-bound rather than permanent privileged application access.

Conceptually:

```text
No elevated access
        ↓
Incident / approved maintenance
        ↓
Strong authentication
        ↓
Reason + ticket/reference
        ↓
Temporary privilege
        ↓
Controlled operation
        ↓
Automatic expiry
        ↓
Audit review
```

Emergency access must not be implemented as a tenant-facing `god_mode` role.

## Abuse and Failure Controls

The architecture must protect against:

- a compromised application credential;
- a tenant attempting cross-tenant access;
- a reporting query consuming excessive resources;
- a worker accidentally mutating unrelated data;
- leaked migration credentials;
- forgotten emergency privileges;
- pooled connection context leakage.

## Consequences

### Positive

- Smaller blast radius for application compromise.
- Reporting can scale independently later.
- Heavy analytics can be scheduled away from peak transaction periods.
- Database schema authority remains outside normal runtime credentials.
- Emergency platform access remains attributable and temporary.

### Trade-off

Operational infrastructure becomes more deliberate: deployment, monitoring, scheduling, and privileged access require explicit configuration rather than one unrestricted database credential.
