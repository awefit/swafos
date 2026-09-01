# ADR-017 — Trusted Database Session Context V0.1

Status: Accepted
Date: 2026-09-01

## Decision

SWAFOS establishes tenant context only inside a database transaction through a controlled SECURITY DEFINER function. The context is transaction-local and fails closed.
The database context is derived from server-side authentication/authorization state, never from arbitrary client input.

Required context for tenant business access:
- user_id
- organization_id
- membership_id
- session_id
- optional service_identity_id
- optional job_id
- correlation_id

Human access requires an ACTIVE membership. Multi-organization users must explicitly select an organization; the server validates the membership before context creation.
Service/background/reporting execution must provide an explicit scoped identity and tenant context. A generic worker identity never implies unrestricted tenant access.

## Transaction lifecycle

BEGIN -> authenticate -> resolve/authorize membership/action -> set trusted transaction context -> execute queries -> RLS -> COMMIT or ROLLBACK.

The trusted context is cleared automatically at transaction end because it uses PostgreSQL transaction-local settings.

## Fail-closed invariants

1. Missing organization context denies tenant data access.
2. Invalid UUID context denies access.
3. Non-existent organization denies access.
4. Non-ACTIVE organization denies access.
5. Missing user context denies human tenant access.
6. Missing membership context denies human tenant access.
7. Membership not ACTIVE denies access.
8. Membership/user/organization mismatch denies access.
9. Session mismatch denies access where session context is required.
10. Revoked/expired session cannot establish trusted context.
11. Revoked/suspended device cannot establish trusted context where device is required.
12. Client cannot directly choose arbitrary database session variables.
13. Context does not survive COMMIT or ROLLBACK.
14. Pooled connections must not retain tenant context.

## Connection pooling

Application/database roles must not use session-level tenant state for request authorization.
Use transaction-local settings (SET LOCAL / set_config(..., true)) or an equivalent transaction-scoped mechanism.
Every transaction that accesses tenant-owned data must establish context before the first protected query.

Pool reuse test: request A establishes Org A; request A ends; the same physical connection serves request B; request B without context receives no tenant rows; request B with Org B context receives only Org B rows.

## RLS contract

RLS policies will read trusted context through narrowly defined functions:
- swafos.current_user_id()
- swafos.current_organization_id()
- swafos.current_membership_id()
- swafos.current_session_id()

Each returns NULL when context is absent. RLS policies treat NULL as deny.

## Context establishment

A controlled function validates actor identity, organization, membership, membership status, session status/expiry, optional device trust, and service/job scope where applicable.
Only the application security role may execute the context-establishment function.
Business application roles do not receive direct UPDATE rights on security tables.

## Rollback

Context setup and business mutations occur in the same transaction where practical. On rollback, business mutations roll back and transaction-local context disappears. A new transaction starts with no tenant context.
Security/audit persistence that must survive a failed business transaction should use a separate controlled audit mechanism or durable event pipeline; it must never weaken tenant isolation.

## Context leakage

No request may rely on a context established by an earlier request.
Tests must cover sequential pool reuse, concurrent requests, commit, rollback, exception paths, retry paths, organization switching, and membership revocation between transactions.

## Multi-organization users

A user with multiple ACTIVE memberships does not get implicit organization selection.
The request may contain an application-level selected organization identifier, but this is only lookup input. The context function verifies it against the authenticated user and ACTIVE membership.
The client never writes organization_id into trusted DB context directly.

## Service accounts

Service identities are not human users. A service execution context must contain service identity, explicit capability/scope, explicit organization scope when tenant data is accessed, and correlation/job identifier.
No wildcard tenant scope is permitted for ordinary workers.

## Background and reporting jobs

Every job carries organization_id, job_id, service identity, and permitted capability.
Reporting jobs additionally evaluate tenant REPORTING_POLICY before execution. Reporting windows are flexible and controlled by tenant SOP; platform resource limits may delay work even inside an allowed window.

## Sensitive actions

Restricted operations may perform a fresh membership/session/device/policy check immediately before mutation.
Examples: capital movement, investor allocation, growth allocation deployment, expansion commitment, high-value procurement, permission/security changes, and break-glass activation.

## Break-glass

Platform emergency access is never a permanent role. It requires explicit activation, strong authentication, reason/reference, time-bound expiry, attribution, audit, and automatic invalidation at expiry.
No tenant-facing role receives platform emergency capability.

## Implementation notes

The migration must define context helper functions before final RLS policies. Helper functions should be owned by a dedicated security owner role and executable only by controlled application roles.
SECURITY DEFINER is not a substitute for authorization; the function must validate all context fields before setting them.

## Acceptance tests

The gate passes only when automated tests demonstrate valid tenant access, no-context denial, invalid-context denial, revoked-membership denial, expired-session denial, revoked-device denial, multi-tenant isolation, service scope isolation, reporting job scope, rollback clearing context, pooled connection reuse without leakage, concurrent tenant isolation, and break-glass expiry.