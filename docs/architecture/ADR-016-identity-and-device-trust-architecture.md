# ADR-016 — Identity & Device Trust Architecture

- Status: Accepted
- Date: 2026-09-01
- Scope: SWAFOS Identity, Device Trust, Session, Organization Membership, and Security Events

## Context

SWAFOS is a multi-tenant business operating system. Identity must support human users, multiple organization memberships, registered devices, tenant security policies, service identities, background jobs, reporting jobs, and auditable high-risk actions.

Identity, authentication, authorization, device trust, network signals, and organization membership are deliberately separate concepts.

## Decision

### 1. Identity

A user represents a human identity. User lifecycle is retained historically:

```
INVITED -> PENDING_ACTIVATION -> ACTIVE -> SUSPENDED -> DEACTIVATED
```

Deactivation does not delete the identity or historical actor references.

Credentials are separate from the user entity. SWAFOS must not store plaintext passwords, OTPs, private keys, or session secrets.

### 2. Credentials and MFA

Authentication credentials are modeled independently so SWAFOS can support password, passkey, SSO, or other supported mechanisms without changing the identity model.

MFA enrollment and MFA verification are distinct states. Sensitive actions may require recent step-up authentication even when MFA is enrolled.

### 3. Sessions

A session is temporary access associated with a user and, where applicable, a registered device.

Sessions carry authentication/security level and lifecycle metadata. Sessions can expire or be explicitly revoked.

Revoking a device must be able to revoke associated active sessions.

### 4. Registered Devices

A device is a security/trust principal associated with a user.

Device records are retained for audit even after revocation.

Device trust must not depend only on mutable labels such as browser name, device name, or user-agent. Where supported, device enrollment should establish a cryptographic device identity; SWAFOS stores a reference/public identity, not the private key.

Device lifecycle:

```
PENDING -> TRUSTED -> SUSPENDED -> REVOKED
```

Recovery and re-enrollment must be explicit and auditable.

### 5. IP and Network Signals

IP address is a network/risk signal, not a user or device identity.

Tenant SOPs may define trusted/blocked networks or require trusted network conditions for sensitive actions. Mobile, NAT, VPN, proxy, IPv6, and changing ISP addresses must not inherently invalidate a trusted device.

Platform security minimums cannot be disabled by tenant policy.

### 6. Organization Membership

A user may belong to multiple organizations. Organization membership is separate from the user.

A membership contains contextual authorization such as role and status.

Lifecycle:

```
INVITED -> ACTIVE -> SUSPENDED -> REVOKED
```

A revoked membership denies organization access while preserving historical records.

For multi-organization users, the active organization must be explicitly selected and server-validated before a trusted database context is established.

### 7. Authorization

Authorization is contextual:

```
Identity
+ Active Membership
+ Organization Context
+ Permission
+ Security Policy
+ Action Risk
= Authorization Decision
```

Roles map to permissions, but role alone is not sufficient for high-risk actions.

Security requirements are action-sensitive:

- STANDARD — routine operations;
- ELEVATED — higher-impact operational/financial actions;
- RESTRICTED — sensitive financial/capital/approval actions;
- BREAK_GLASS — temporary emergency platform access.

### 8. Trusted Database Context

Database tenant context is transaction-local.

Conceptual request flow:

```
Authenticate
 -> validate device/network
 -> resolve membership
 -> authorize action
 -> BEGIN
 -> establish trusted context
 -> execute SQL
 -> RLS
 -> COMMIT/ROLLBACK
```

The trusted context must contain, as applicable:

- user_id;
- organization_id;
- membership_id;
- session_id;
- service_identity/job_id for non-human execution.

Client input must never be trusted as an arbitrary organization context.

If organization or membership context is absent/invalid, tenant-owned data access fails closed.

### 9. Connection Pooling

Tenant context must not survive the transaction.

The implementation must be safe when the same pooled database connection serves different users or organizations.

Security tests must deliberately reuse pooled connections across organizations and verify zero cross-tenant leakage.

### 10. Service and Background Identities

Service accounts are separate from human users.

Every service identity must have explicit capability and, where applicable, organization scope.

Background and reporting jobs must establish explicit tenant context. A generic worker identity must not imply unrestricted access to every tenant.

### 11. Security Events

Security-sensitive events are append-oriented audit records and must retain enough metadata for investigation without storing secrets.

Examples:

- LOGIN_SUCCESS / LOGIN_FAILED;
- DEVICE_REGISTERED / DEVICE_REVOKED;
- MFA_ENABLED / MFA_FAILED;
- SESSION_CREATED / SESSION_REVOKED;
- ORGANIZATION_SWITCHED;
- MEMBERSHIP_CREATED / MEMBERSHIP_REVOKED;
- PRIVILEGE_ESCALATED;
- BREAK_GLASS_ACTIVATED / BREAK_GLASS_EXPIRED.

Business-sensitive actions can reference the same correlation mechanism.

Security events should include actor, organization where applicable, device/session where applicable, timestamp, result, action/resource, and correlation identifier.

### 12. Recovery

Loss of a trusted device must not become an authentication bypass.

Recovery should support identity verification, restricted temporary access where appropriate, new-device enrollment, and explicit revocation of lost devices. Higher-risk users/actions may require additional approval according to tenant SOP and platform minimums.

### 13. No Permanent God Mode

No tenant-facing or application-facing role receives unrestricted authority.

Awefit platform emergency access remains break-glass and time-bound, with strong authentication, reason/reference, automatic expiry, and audit.

## Security Invariants

The following are mandatory invariants:

1. No plaintext credential or private device key is stored by SWAFOS.
2. No client can select an arbitrary tenant context and bypass authorization.
3. Missing or invalid organization context fails closed.
4. Revoked membership cannot authorize new organization activity.
5. Revoked devices cannot establish new trusted sessions.
6. Transaction-local context prevents pooled-connection tenant leakage.
7. IP is never the sole identity of a user or device.
8. Historical identity, device, membership, and security records are not hard-deleted when needed for audit.
9. Service/background identities are explicitly scoped.
10. High-risk actions can require step-up authentication and additional approval.
11. Emergency platform privileges are temporary, attributable, and auditable.

## Schema Direction

The initial relational model should separate at least:

```
users
user_credentials
user_mfa_methods
sessions
devices
device_registrations
organizations
organization_memberships
roles
permissions
role_permissions
security_policies
security_events
recovery_events
```

The exact schema, foreign keys, indexes, unique constraints, status transitions, and RLS policies are to be defined in the implementation migration after this ADR.

## Consequences

### Positive

- Strong separation between identity and authorization.
- Multi-tenant access is explicit.
- Device trust can evolve without changing business domains.
- Network policies can accommodate real-world connectivity.
- Sensitive actions can use step-up controls.
- Background/reporting execution remains attributable.
- Connection pooling is safe by design.
- Historical auditability is preserved.

### Trade-offs

- More entities and lifecycle states than a simple user table.
- Device enrollment/recovery requires operational UX.
- Security policy evaluation becomes a platform capability.
- More integration testing is required before production.

## Implementation Gate

Identity & Device Core is not considered complete until automated tests cover:

- normal authentication;
- multi-organization switching;
- revoked membership;
- revoked device;
- unknown device;
- network policy violation;
- connection pool reuse;
- service identity scope;
- background/reporting tenant scope;
- transaction rollback;
- expired break-glass access;
- cross-tenant access denial.

After this gate, SWAFOS can proceed to Production Core.
