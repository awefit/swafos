# ADR-011 — Security Model & Awefit Protection Boundary

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-009, ADR-010, SCHEMA-CONSISTENCY-REVIEW-V0.1

## Decision

SWAFOS will use defense-in-depth security consisting of authentication, organization membership, role/permission authorization, approval controls, PostgreSQL Row-Level Security (RLS), auditability, and least-privilege service access.

The security model explicitly protects the `awefit` platform owner/maintainer boundary from ordinary tenant, business-user, operator, support, integration, or service-account actions.

## No God Mode

SWAFOS will not define a normal application role named `god`, `god_mode`, `super_user`, or equivalent unrestricted business role.

Platform maintenance authority and business-data authority are separate concerns.

## Awefit Protection Boundary

The `awefit` platform/maintainer boundary must not be modifiable by tenant-level business roles.

Tenant users may manage their own organizations and business data according to authorization policy, but cannot:

- change platform ownership;
- grant themselves platform-maintainer privileges;
- modify platform security policy;
- modify another tenant's organization boundary;
- disable or bypass RLS through application permissions;
- alter platform-wide billing/licensing/security configuration;
- impersonate platform maintainers;
- delete or rewrite platform audit history.

The application must never expose a tenant-level permission that can mutate these controls.

## Platform Maintenance

Technical infrastructure access may exist outside the application role model when required for deployment, operations, incident response, or maintenance. Such access is infrastructure authority, not an application `god mode` role.

Where technically supported, privileged infrastructure access should be:

- least privilege;
- authenticated strongly;
- time-limited where practical;
- attributable to a named human or controlled service identity;
- logged;
- protected from ordinary tenant credentials.

## Tenant Boundary

Every tenant-owned business record must be associated with an organization. PostgreSQL RLS will enforce row-level tenant isolation independently from application filters.

Application authorization remains responsible for role, permission, workflow, and business-action checks.

## Role / Permission Model

Roles are permission bundles, not unrestricted authorities.

Examples include:

- owner;
- manager;
- finance;
- operator;
- farm manager;
- seller;
- collector;
- warehouse;
- delivery;
- auditor;
- investor.

Exact role definitions may evolve, but platform-maintainer authority is not granted through tenant roles.

## Approval Separation

Sensitive workflows distinguish:

```text
Create
  ≠
Approve
  ≠
Execute
```

This applies to material actions such as:

- financial adjustments;
- capital transactions;
- expansion funding;
- loans;
- profit allocation;
- material asset purchases;
- other configurable high-risk actions.

## Service Accounts

Service accounts follow least privilege and are scoped to explicit capabilities. They must not receive unrestricted application access merely because they run background jobs.

## Audit

Security-sensitive actions must be auditable, including:

- authorization changes;
- role/permission changes;
- allocation approvals;
- financial adjustments;
- capital and loan changes;
- expansion approvals;
- platform-support access where applicable.

Historical audit records are append-oriented and are not ordinary tenant-editable data.

## Emergency Access

If infrastructure requires emergency privileged access, it is treated as a separate operational control, not as a normal application role. Emergency access must be attributable and audited.

## Consequences

### Positive

- Strong tenant isolation.
- Clear separation between business authority and platform authority.
- Protection of the `awefit` platform boundary.
- Reduced blast radius from compromised tenant accounts.
- Better auditability and governance.

### Constraint

No application architecture can guarantee absolute protection against a person who has unrestricted infrastructure/root access outside the application. Therefore platform protection must also include repository permissions, deployment controls, secrets management, infrastructure IAM, backups, and audit controls outside SWAFOS itself.
