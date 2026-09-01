# ADR-012 — PostgreSQL RLS Policy Design V0.1

- Status: Proposed for review
- Date: 2026-09-01
- Depends on: ADR-011

## 1. Objective

PostgreSQL Row-Level Security (RLS) is the database-level tenant isolation boundary for SWAFOS. It complements, and does not replace, application authorization.

## 2. Session Context

The application must establish trusted transaction-local database context after authentication and organization authorization:

```text
app.user_id
app.organization_id
app.membership_id
```

The context must be set using a mechanism that ordinary tenant users cannot arbitrarily forge. The preferred implementation is a controlled database role/function boundary rather than allowing clients to issue unrestricted `SET` commands directly.

## 3. Core Tenant Policy

For tenant-owned tables:

```text
USING:
    organization_id = current organization context

WITH CHECK:
    organization_id = current organization context
```

This protects both reads and writes.

A user authenticated into Organization A therefore cannot read or insert rows belonging to Organization B.

## 4. Application Authorization vs RLS

RLS answers:

> Which rows may this database session access?

Application authorization answers:

> Which business actions may this authenticated actor perform?

Examples:

- RLS allows a finance user to access the organization's costs.
- Application authorization decides whether that finance user may create or approve a financial adjustment.

Both checks are required.

## 5. Tenant-Owned Tables

The following classes are tenant-owned and should be protected by RLS:

- organizations and organization memberships where appropriate;
- business actors;
- locations;
- production records;
- production units;
- lots;
- inventory movements;
- sales and orders;
- revenues;
- costs;
- capital sources and transactions;
- loans and payments;
- assets and depreciation;
- cash accounts and transactions;
- allocation policies, rules, runs and entitlements;
- growth funds and transactions;
- expansion initiatives and funding plans;
- delivery records when implemented;
- audit records belonging to a tenant.

## 6. Cross-Tenant Prohibition

Tenant application roles must never be granted a permission that bypasses RLS or changes the RLS policy itself.

Cross-tenant reporting, if required in the future, must use an explicit controlled reporting architecture rather than weakening tenant policies.

## 7. Awefit Platform Boundary

Platform-owned configuration and infrastructure metadata must not be exposed as ordinary tenant-owned rows.

Tenant roles cannot modify:

- RLS policies;
- database ownership;
- platform security configuration;
- platform administrator identities;
- platform audit controls;
- cross-tenant infrastructure configuration.

Platform operations remain outside ordinary tenant RBAC.

## 8. Write Integrity

`WITH CHECK` must be enforced on all tenant-owned writes. This prevents a valid tenant session from inserting or updating a row so that its `organization_id` changes to another tenant.

For organization identifiers that must never change after creation, application and database constraints should additionally prevent tenant reassignment.

## 9. Transaction Context

Organization context should be transaction-local whenever practical:

```text
BEGIN
  establish authenticated user + organization context
  perform application-authorized operation
  database RLS validates rows
COMMIT
```

This reduces context leakage risk between pooled database connections.

## 10. Security Definer Functions

Any `SECURITY DEFINER` function must:

- have a fixed, trusted `search_path`;
- expose the smallest possible operation;
- avoid dynamic SQL unless strictly necessary;
- validate caller context;
- be owned by a controlled database role;
- not provide a generic arbitrary-SQL escape hatch.

## 11. Service Accounts

Background services receive explicit organization context where they act on tenant data. A service identity must not be granted unrestricted cross-tenant access merely for convenience.

Platform-wide jobs that genuinely require aggregated data should operate through a separately controlled reporting/service boundary.

## 12. Bypass Authority

Application roles must not have `BYPASSRLS`.

Any infrastructure/database operator capable of bypassing RLS is outside the application authorization boundary and must be governed by infrastructure IAM, repository/deployment controls, secrets management, and audit procedures described in ADR-011.

## 13. Audit

Security-sensitive RLS context changes, privileged functions, authorization changes, and sensitive business actions should be auditable. Audit records must not be tenant-editable through normal application roles.

## 14. Testing Requirements

Before RLS is considered production-ready, automated tests must prove at minimum:

1. Organization A cannot read Organization B data.
2. Organization A cannot insert a row for Organization B.
3. Organization A cannot update a row into Organization B.
4. Revoked/suspended membership cannot access tenant data.
5. Role permissions still restrict business actions after RLS permits the row.
6. Allocation approval cannot be executed by a role lacking approval/execution permission.
7. Financial adjustments retain audit history.
8. Service accounts cannot accidentally gain unrestricted tenant access.
9. Platform-owned controls cannot be modified by tenant roles.

## 15. Proposed Implementation Pattern

```text
Client
  ↓
Authentication
  ↓
Application Authorization
  ↓
Controlled DB Session Context
  ↓
PostgreSQL RLS
  ↓
Constraints / Foreign Keys
  ↓
Data
```

No client-facing API should receive direct unrestricted database credentials.

## 16. Review Gate

This ADR is intentionally marked **Proposed for review**. The SQL policies and exact database role/function implementation must not be treated as final until the owner approves this security boundary.
