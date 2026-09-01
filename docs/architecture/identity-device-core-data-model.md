# SWAFOS Identity & Device Core — ERD, Dependency Graph, Constraints & Indexes

Status: Accepted design
Date: 2026-09-01

## 1. ERD

users 1---< user_credentials
users 1---< user_mfa_methods
users 1---< sessions >--- devices 1---< device_registrations
users 1---< organization_memberships >--- organizations
organization_memberships >--- roles >--- role_permissions >--- permissions
organizations 1---< security_policies
organizations 1---< action_security_requirements (platform catalog may be global)
organizations 1---< authorization_decisions
organizations 1---< security_events
organizations 1---< recovery_events

## 2. Dependency Graph

1. users
2. organizations
3. permissions
4. roles
5. role_permissions
6. organization_memberships
7. user_credentials
8. user_mfa_methods
9. devices
10. device_registrations
11. sessions
12. security_policies
13. action_security_requirements
14. authorization_decisions
15. recovery_events
16. security_events

security_events is last in dependency order and uses nullable historical references so audit rows can survive lifecycle changes.

## 3. Core Rules

- UUID primary keys; IDs are opaque and immutable.
- timestamptz for system timestamps.
- Organization timezone controls business/reporting semantics.
- No plaintext password, OTP, private key, access token, or session secret is stored.
- No hard-delete for security history.

## 4. users

Columns: id UUID PK; display_name TEXT NOT NULL; email TEXT NULL; email_normalized TEXT NULL; phone TEXT NULL; status TEXT NOT NULL; created_at timestamptz NOT NULL; updated_at timestamptz NOT NULL.

Checks: status IN (INVITED, PENDING_ACTIVATION, ACTIVE, SUSPENDED, DEACTIVATED); display_name must be non-empty after trim.
Indexes: unique partial index on email_normalized where not null; status; created_at.

## 5. organizations

Columns: id UUID PK; name TEXT NOT NULL; status TEXT NOT NULL; timezone TEXT NOT NULL; created_at; updated_at.
Checks: status IN (ACTIVE, SUSPENDED, DEACTIVATED); name non-empty. IANA timezone validity is enforced at domain/application boundary.
Indexes: status; name.

## 6. permissions

Columns: id UUID PK; key TEXT NOT NULL UNIQUE; description TEXT NOT NULL; security_level TEXT NOT NULL; is_platform_reserved BOOLEAN NOT NULL DEFAULT FALSE; created_at.
Security levels: STANDARD, ELEVATED, RESTRICTED, BREAK_GLASS.
Permission keys are stable; deprecate rather than silently reuse keys.

## 7. roles

Columns: id UUID PK; organization_id UUID NULL; key TEXT NOT NULL; name TEXT NOT NULL; is_system BOOLEAN NOT NULL DEFAULT FALSE; status TEXT NOT NULL; created_at; updated_at.
Tenant custom roles have organization_id. Platform role templates may be global only under explicit platform rules.
Checks: status IN (ACTIVE, SUSPENDED, DEACTIVATED).
Indexes: unique (organization_id, key) for tenant roles; organization_id; status.
Tenant users cannot modify system roles or grant platform-reserved permissions.

## 8. role_permissions

Columns: role_id UUID NOT NULL FK roles; permission_id UUID NOT NULL FK permissions; created_at.
Primary key: (role_id, permission_id).
No duplicate grants.

## 9. organization_memberships

Columns: id UUID PK; organization_id UUID NOT NULL FK organizations; user_id UUID NOT NULL FK users; role_id UUID NOT NULL FK roles; status TEXT NOT NULL; joined_at; revoked_at; created_at; updated_at.
Checks: status IN (INVITED, ACTIVE, SUSPENDED, REVOKED); revoked_at required iff status=REVOKED.
Unique active membership: (organization_id, user_id) where status IN (INVITED, ACTIVE, SUSPENDED).
Indexes: user_id; organization_id; role_id; status.
Role ownership must be enforced: a membership cannot reference another tenant's custom role.

## 10. user_credentials

Columns: id UUID PK; user_id UUID NOT NULL FK users; credential_type TEXT NOT NULL; provider TEXT NULL; credential_reference TEXT NULL; secret_hash TEXT NULL; status TEXT NOT NULL; created_at; last_used_at; revoked_at.
Credential types: PASSWORD, PASSKEY, SSO, OTHER. Status: ACTIVE, SUSPENDED, REVOKED.
Checks: revoked_at required iff status=REVOKED.
Indexes: user_id; status; (user_id, credential_type).

## 11. user_mfa_methods

Columns: id UUID PK; user_id UUID NOT NULL FK users; method_type TEXT NOT NULL; provider TEXT NULL; credential_reference TEXT NULL; status TEXT NOT NULL; created_at; verified_at; last_used_at; revoked_at.
Status: PENDING, ACTIVE, REVOKED. verified_at required for ACTIVE; revoked_at required for REVOKED.
Indexes: user_id; status; (user_id, method_type).

## 12. devices

Columns: id UUID PK; user_id UUID NOT NULL FK users; device_type TEXT NOT NULL; platform TEXT NULL; device_public_key_reference TEXT NULL; status TEXT NOT NULL; registered_at; last_seen_at; revoked_at.
Status: PENDING, TRUSTED, SUSPENDED, REVOKED. revoked_at required for REVOKED.
Private device keys are never stored by SWAFOS.
Indexes: user_id; status; last_seen_at.

## 13. device_registrations

Columns: id UUID PK; device_id UUID NOT NULL FK devices; user_id UUID NOT NULL FK users; registration_method TEXT NOT NULL; status TEXT NOT NULL; initiated_at; verified_at; completed_at; revoked_at; correlation_id UUID NULL.
Status: INITIATED, VERIFIED, COMPLETED, REVOKED, FAILED.
Checks: device.user_id must equal registration.user_id; lifecycle timestamps must be ordered.
Indexes: device_id; user_id; status; correlation_id.

## 14. sessions

Columns: id UUID PK; user_id UUID NOT NULL FK users; device_id UUID NULL FK devices; authentication_level TEXT NOT NULL; status TEXT NOT NULL; created_at; last_activity_at; expires_at; revoked_at.
Authentication levels: STANDARD, ELEVATED, RESTRICTED. Status: ACTIVE, EXPIRED, REVOKED.
Checks: expires_at > created_at; revoked_at required for REVOKED; device must belong to user when present.
Indexes: user_id; device_id; status; expires_at; last_activity_at.

## 15. security_policies

Columns: id UUID PK; organization_id UUID NOT NULL FK organizations; policy_type TEXT NOT NULL; version INTEGER NOT NULL; status TEXT NOT NULL; configuration JSONB NOT NULL; effective_from timestamptz NOT NULL; effective_to timestamptz NULL; created_by_user_id UUID NULL FK users; created_at.
Policy types: DEVICE_POLICY, NETWORK_POLICY, MFA_POLICY, SESSION_POLICY, REPORTING_POLICY, RECOVERY_POLICY.
Status: DRAFT, ACTIVE, SUPERSEDED, RETIRED.
Constraints: unique version per organization/policy type; only one ACTIVE version; effective_to > effective_from when present.
Indexes: (organization_id, policy_type, status); (organization_id, policy_type, effective_from).
Reporting window is tenant SOP; platform resource protection may delay/deny heavy jobs even during an allowed tenant window.

## 16. action_security_requirements

Columns: id UUID PK; action_key TEXT NOT NULL UNIQUE; security_level TEXT NOT NULL; require_registered_device BOOLEAN NOT NULL DEFAULT FALSE; require_mfa BOOLEAN NOT NULL DEFAULT FALSE; require_recent_mfa_seconds INTEGER NULL; require_trusted_network BOOLEAN NOT NULL DEFAULT FALSE; require_approval BOOLEAN NOT NULL DEFAULT FALSE; is_platform_reserved BOOLEAN NOT NULL DEFAULT FALSE; created_at; updated_at.
Checks: recent MFA seconds positive when present; BREAK_GLASS requires registered device and MFA unless a documented platform emergency exception exists.
Indexes: security_level; is_platform_reserved.

## 17. authorization_decisions

Columns: id UUID PK; user_id UUID NULL FK users; organization_id UUID NULL FK organizations; membership_id UUID NULL FK organization_memberships; session_id UUID NULL FK sessions; device_id UUID NULL FK devices; action_key TEXT NOT NULL; decision TEXT NOT NULL; reason_code TEXT NOT NULL; correlation_id UUID NULL; decided_at timestamptz NOT NULL.
Decision: ALLOW, DENY, STEP_UP_REQUIRED.
Append-oriented. Indexes: (organization_id, decided_at); (user_id, decided_at); (action_key, decided_at); correlation_id.

## 18. recovery_events

Columns: id UUID PK; user_id UUID NOT NULL FK users; organization_id UUID NULL FK organizations; device_id UUID NULL FK devices; recovery_type TEXT NOT NULL; status TEXT NOT NULL; initiated_at; completed_at; correlation_id UUID NULL; metadata JSONB NOT NULL DEFAULT '{}'.
Recovery types: LOST_DEVICE, ACCOUNT_RECOVERY, DEVICE_REENROLLMENT, OTHER.
Status: INITIATED, APPROVED, REJECTED, COMPLETED, EXPIRED, CANCELLED.
Indexes: user_id; organization_id; device_id; status; correlation_id.

## 19. security_events

Columns: id UUID PK; event_type TEXT NOT NULL; actor_user_id UUID NULL FK users; organization_id UUID NULL FK organizations; device_id UUID NULL FK devices; session_id UUID NULL FK sessions; resource_type TEXT NULL; resource_id UUID NULL; result TEXT NOT NULL; correlation_id UUID NULL; occurred_at timestamptz NOT NULL; metadata JSONB NOT NULL DEFAULT '{}'.
Result: SUCCESS, FAILURE, DENIED.
Append-only. No secrets in metadata.
Indexes: (organization_id, occurred_at); (actor_user_id, occurred_at); (event_type, occurred_at); correlation_id.

## 20. Cross-table integrity

Use FK constraints plus controlled functions/triggers where CHECK constraints cannot validate another table.
Critical invariants: membership role belongs to same organization; device registration user equals device user; session device belongs to session user; tenant role cannot grant platform-reserved permission; only one active policy version; revoked statuses require timestamps.

## 21. RLS Direction

RLS is mandatory for tenant-owned data. User/device/session records are restricted to their owner or authorized security administration. Tenant policies are organization-scoped. Platform-reserved configuration is not tenant-writable. Missing or invalid organization context fails closed.
RLS must not trust arbitrary client-supplied organization IDs.

## 22. Delete Policy

Default FK behavior is RESTRICT/no cascade for identity/security history.
Do not hard-delete security_events, authorization_decisions, recovery_events, historical memberships, or historical device registrations. Prefer lifecycle status.

## 23. Indexing Philosophy

Indexes must support authentication/session lookup, organization membership lookup, RLS predicates, security investigation, policy/reporting scheduling, and device/session revocation. Avoid speculative indexes until query patterns justify them.

## 24. Migration Gate

The implementation migration must create tables in dependency order, FK/CHECK constraints, partial/unique indexes, initial RLS scaffolding, controlled grants, and append-only protection for audit tables where practical.
Business production tables must reference stable identity contracts only after this migration is accepted.