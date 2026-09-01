# ADR-014 — Trusted Database Session Context

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-012, ADR-013

## Decision

SWAFOS establishes database tenant context only after authentication, membership resolution, and application authorization. The context is transaction-local and is never accepted as an arbitrary tenant identifier supplied by the client.

```text
Authentication
      ↓
Membership
      ↓
Authorization
      ↓
BEGIN transaction
      ↓
Trusted DB context
      ↓
SQL
      ↓
RLS
      ↓
COMMIT / ROLLBACK
```

## Context

A trusted transaction context contains, where applicable:

- authenticated user identity;
- active organization identity;
- active membership identity;
- service identity for non-human execution;
- job/report identity for asynchronous work.

The database must fail closed when required context is absent or invalid.

## Transaction-local Requirement

Tenant/security context must be transaction-local rather than persistent connection/session state.

This is mandatory because SWAFOS will use connection pooling. A pooled connection may serve different users and organizations over time. Context from one request must never leak into another request.

Conceptually:

```text
Request A
  BEGIN
  context = Organization A
  queries
  COMMIT
  context disappears

Request B
  BEGIN
  context = Organization B
  queries
  COMMIT
  context disappears
```

Rollback must discard the transaction and its security context together.

## Client-Controlled Context Prohibited

The client may request an organization switch, but it cannot directly establish an arbitrary database tenant context.

The application must:

1. authenticate the user;
2. resolve active memberships;
3. verify that the requested organization is an active membership;
4. resolve the effective permissions;
5. begin the database transaction;
6. establish the trusted context through a controlled server-side mechanism;
7. execute the transaction under RLS.

## Multi-Organization Users

A user with multiple active memberships must have an explicit active organization for tenant-scoped operations.

No organization is silently inferred when more than one valid membership exists.

Organization switching should generate a security event.

## Revoked Memberships

A revoked or inactive membership must not establish a new trusted tenant context.

Sensitive operations should perform a fresh authorization check as close as practical to final execution. This is especially important for:

- financial adjustments;
- capital movements;
- allocation execution;
- expansion funding;
- other irreversible or high-impact actions.

## Service Accounts

Non-human identities do not require human memberships. They must instead have explicit service identity, organization scope where applicable, and capability scope.

A service identity must not implicitly receive cross-tenant authority merely because it is a worker.

## Background Jobs

Background jobs must carry explicit execution metadata, including where applicable:

- job_id;
- organization_id;
- service identity;
- capability;
- execution timestamps;
- status.

The worker establishes trusted context for the specific job before accessing tenant data.

## Reporting Jobs

Reporting jobs are tenant-scoped unless explicitly designated as controlled platform reporting. A tenant report must execute under the tenant's reporting boundary and `readonly_reporting` privileges.

Heavy reports remain subject to the tenant-configured reporting SOP/window and platform resource protection defined by ADR-013.

## Connection Pooling and Context Leakage

Security tests must verify repeated organization switching over reused pooled connections, for example:

```text
A → B → A → B
```

No request may observe data or context belonging to a previous request.

## Fail-Closed Rules

Tenant data access is denied when:

- user identity is absent when required;
- organization context is absent when required;
- membership is inactive or revoked;
- organization and membership do not match;
- required permission is absent;
- context validation fails;
- a service/job scope is missing or invalid.

The system must never fall back to a default organization for tenant-owned data.

## Authorization Layers

SWAFOS uses defense in depth:

```text
Authentication
      +
Membership / Organization boundary
      +
Application permission
      +
Trusted transaction context
      +
PostgreSQL RLS
      +
Constraints / foreign keys
      +
Audit
```

Each layer answers a different security question and must not be treated as a substitute for the others.

## Consequences

### Positive

- Strong tenant isolation under connection pooling.
- Reduced risk of forged organization context.
- Clear handling of human and non-human execution.
- Security context naturally expires with the transaction.
- Sensitive operations can enforce fresh authorization.

### Trade-offs

The application/database boundary becomes more explicit. Context establishment, pooling behavior, service jobs, and authorization failures require integration tests rather than relying only on unit tests.
