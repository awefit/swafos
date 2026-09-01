-- SWAFOS Identity & Device Core V0.1
-- Migration 0004
-- Security note: RLS is enabled here but tenant policies are intentionally deferred
-- until the trusted transaction-local session context is implemented.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name text NOT NULL CHECK (btrim(display_name) <> ''),
    email text,
    email_normalized text,
    phone text,
    status text NOT NULL CHECK (status IN ('INVITED','PENDING_ACTIVATION','ACTIVE','SUSPENDED','DEACTIVATED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ux_users_email_normalized ON users (email_normalized) WHERE email_normalized IS NOT NULL;
CREATE INDEX ix_users_status ON users (status);
CREATE INDEX ix_users_created_at ON users (created_at);

CREATE TABLE organizations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL CHECK (btrim(name) <> ''),
    status text NOT NULL CHECK (status IN ('ACTIVE','SUSPENDED','DEACTIVATED')),
    timezone text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ix_organizations_status ON organizations (status);
CREATE INDEX ix_organizations_name ON organizations (name);

CREATE TABLE permissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    key text NOT NULL UNIQUE CHECK (btrim(key) <> ''),
    description text NOT NULL CHECK (btrim(description) <> ''),
    security_level text NOT NULL CHECK (security_level IN ('STANDARD','ELEVATED','RESTRICTED','BREAK_GLASS')),
    is_platform_reserved boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ix_permissions_security_level ON permissions (security_level);

CREATE TABLE roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id uuid REFERENCES organizations(id) ON DELETE RESTRICT,
    key text NOT NULL CHECK (btrim(key) <> ''),
    name text NOT NULL CHECK (btrim(name) <> ''),
    is_system boolean NOT NULL DEFAULT false,
    status text NOT NULL CHECK (status IN ('ACTIVE','SUSPENDED','DEACTIVATED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_roles_system_scope CHECK ((is_system AND organization_id IS NULL) OR (NOT is_system AND organization_id IS NOT NULL))
);
CREATE UNIQUE INDEX ux_roles_tenant_key ON roles (organization_id, key) WHERE organization_id IS NOT NULL;
CREATE UNIQUE INDEX ux_roles_system_key ON roles (key) WHERE organization_id IS NULL;
CREATE INDEX ix_roles_organization_id ON roles (organization_id);
CREATE INDEX ix_roles_status ON roles (status);

CREATE TABLE role_permissions (
    role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    permission_id uuid NOT NULL REFERENCES permissions(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (role_id, permission_id)
);
CREATE INDEX ix_role_permissions_permission_id ON role_permissions (permission_id);

CREATE TABLE organization_memberships (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    status text NOT NULL CHECK (status IN ('INVITED','ACTIVE','SUSPENDED','REVOKED')),
    joined_at timestamptz,
    revoked_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_membership_revoked_at CHECK ((status = 'REVOKED' AND revoked_at IS NOT NULL) OR (status <> 'REVOKED' AND revoked_at IS NULL))
);
CREATE UNIQUE INDEX ux_membership_current ON organization_memberships (organization_id, user_id) WHERE status IN ('INVITED','ACTIVE','SUSPENDED');
CREATE INDEX ix_memberships_user_id ON organization_memberships (user_id);
CREATE INDEX ix_memberships_organization_id ON organization_memberships (organization_id);
CREATE INDEX ix_memberships_role_id ON organization_memberships (role_id);
CREATE INDEX ix_memberships_status ON organization_memberships (status);

CREATE TABLE user_credentials (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    credential_type text NOT NULL CHECK (credential_type IN ('PASSWORD','PASSKEY','SSO','OTHER')),
    provider text,
    credential_reference text,
    secret_hash text,
    status text NOT NULL CHECK (status IN ('ACTIVE','SUSPENDED','REVOKED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    last_used_at timestamptz,
    revoked_at timestamptz,
    CONSTRAINT ck_credential_revoked_at CHECK ((status = 'REVOKED' AND revoked_at IS NOT NULL) OR (status <> 'REVOKED' AND revoked_at IS NULL))
);
CREATE INDEX ix_user_credentials_user_id ON user_credentials (user_id);
CREATE INDEX ix_user_credentials_status ON user_credentials (status);
CREATE INDEX ix_user_credentials_user_type ON user_credentials (user_id, credential_type);

CREATE TABLE user_mfa_methods (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    method_type text NOT NULL,
    provider text,
    credential_reference text,
    status text NOT NULL CHECK (status IN ('PENDING','ACTIVE','REVOKED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    verified_at timestamptz,
    last_used_at timestamptz,
    revoked_at timestamptz,
    CONSTRAINT ck_mfa_active_verified CHECK (status <> 'ACTIVE' OR verified_at IS NOT NULL),
    CONSTRAINT ck_mfa_revoked_at CHECK ((status = 'REVOKED' AND revoked_at IS NOT NULL) OR (status <> 'REVOKED' AND revoked_at IS NULL))
);
CREATE INDEX ix_user_mfa_user_id ON user_mfa_methods (user_id);
CREATE INDEX ix_user_mfa_status ON user_mfa_methods (status);
CREATE INDEX ix_user_mfa_user_type ON user_mfa_methods (user_id, method_type);

CREATE TABLE devices (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    device_type text NOT NULL,
    platform text,
    device_public_key_reference text,
    status text NOT NULL CHECK (status IN ('PENDING','TRUSTED','SUSPENDED','REVOKED')),
    registered_at timestamptz NOT NULL DEFAULT now(),
    last_seen_at timestamptz,
    revoked_at timestamptz,
    CONSTRAINT ck_device_revoked_at CHECK ((status = 'REVOKED' AND revoked_at IS NOT NULL) OR (status <> 'REVOKED' AND revoked_at IS NULL))
);
CREATE INDEX ix_devices_user_id ON devices (user_id);
CREATE INDEX ix_devices_status ON devices (status);
CREATE INDEX ix_devices_last_seen_at ON devices (last_seen_at);

CREATE TABLE device_registrations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id uuid NOT NULL REFERENCES devices(id) ON DELETE RESTRICT,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    registration_method text NOT NULL,
    status text NOT NULL CHECK (status IN ('INITIATED','VERIFIED','COMPLETED','REVOKED','FAILED')),
    initiated_at timestamptz NOT NULL DEFAULT now(),
    verified_at timestamptz,
    completed_at timestamptz,
    revoked_at timestamptz,
    correlation_id uuid,
    CONSTRAINT ck_device_registration_times CHECK ((verified_at IS NULL OR verified_at >= initiated_at) AND (completed_at IS NULL OR completed_at >= COALESCE(verified_at, initiated_at)) AND (revoked_at IS NULL OR revoked_at >= initiated_at))
);
CREATE INDEX ix_device_registrations_device_id ON device_registrations (device_id);
CREATE INDEX ix_device_registrations_user_id ON device_registrations (user_id);
CREATE INDEX ix_device_registrations_status ON device_registrations (status);
CREATE INDEX ix_device_registrations_correlation_id ON device_registrations (correlation_id);

CREATE TABLE sessions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    device_id uuid REFERENCES devices(id) ON DELETE RESTRICT,
    authentication_level text NOT NULL CHECK (authentication_level IN ('STANDARD','ELEVATED','RESTRICTED')),
    status text NOT NULL CHECK (status IN ('ACTIVE','EXPIRED','REVOKED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    last_activity_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    CONSTRAINT ck_session_expiry CHECK (expires_at > created_at),
    CONSTRAINT ck_session_revoked_at CHECK ((status = 'REVOKED' AND revoked_at IS NOT NULL) OR (status <> 'REVOKED' AND revoked_at IS NULL))
);
CREATE INDEX ix_sessions_user_id ON sessions (user_id);
CREATE INDEX ix_sessions_device_id ON sessions (device_id);
CREATE INDEX ix_sessions_status ON sessions (status);
CREATE INDEX ix_sessions_expires_at ON sessions (expires_at);
CREATE INDEX ix_sessions_last_activity_at ON sessions (last_activity_at);

CREATE TABLE security_policies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
    policy_type text NOT NULL CHECK (policy_type IN ('DEVICE_POLICY','NETWORK_POLICY','MFA_POLICY','SESSION_POLICY','REPORTING_POLICY','RECOVERY_POLICY')),
    version integer NOT NULL CHECK (version > 0),
    status text NOT NULL CHECK (status IN ('DRAFT','ACTIVE','SUPERSEDED','RETIRED')),
    configuration jsonb NOT NULL DEFAULT '{}',
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    created_by_user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_policy_effective_window CHECK (effective_to IS NULL OR effective_to > effective_from)
);
CREATE UNIQUE INDEX ux_security_policy_version ON security_policies (organization_id, policy_type, version);
CREATE UNIQUE INDEX ux_security_policy_active ON security_policies (organization_id, policy_type) WHERE status = 'ACTIVE';
CREATE INDEX ix_security_policies_lookup ON security_policies (organization_id, policy_type, status);
CREATE INDEX ix_security_policies_effective_from ON security_policies (organization_id, policy_type, effective_from);

CREATE TABLE action_security_requirements (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    action_key text NOT NULL UNIQUE CHECK (btrim(action_key) <> ''),
    security_level text NOT NULL CHECK (security_level IN ('STANDARD','ELEVATED','RESTRICTED','BREAK_GLASS')),
    require_registered_device boolean NOT NULL DEFAULT false,
    require_mfa boolean NOT NULL DEFAULT false,
    require_recent_mfa_seconds integer CHECK (require_recent_mfa_seconds IS NULL OR require_recent_mfa_seconds > 0),
    require_trusted_network boolean NOT NULL DEFAULT false,
    require_approval boolean NOT NULL DEFAULT false,
    is_platform_reserved boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ix_action_security_level ON action_security_requirements (security_level);
CREATE INDEX ix_action_security_reserved ON action_security_requirements (is_platform_reserved);

CREATE TABLE authorization_decisions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
    organization_id uuid REFERENCES organizations(id) ON DELETE RESTRICT,
    membership_id uuid REFERENCES organization_memberships(id) ON DELETE RESTRICT,
    session_id uuid REFERENCES sessions(id) ON DELETE RESTRICT,
    device_id uuid REFERENCES devices(id) ON DELETE RESTRICT,
    action_key text NOT NULL,
    decision text NOT NULL CHECK (decision IN ('ALLOW','DENY','STEP_UP_REQUIRED')),
    reason_code text NOT NULL,
    correlation_id uuid,
    decided_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ix_authz_decisions_org_time ON authorization_decisions (organization_id, decided_at);
CREATE INDEX ix_authz_decisions_user_time ON authorization_decisions (user_id, decided_at);
CREATE INDEX ix_authz_decisions_action_time ON authorization_decisions (action_key, decided_at);
CREATE INDEX ix_authz_decisions_correlation ON authorization_decisions (correlation_id);

CREATE TABLE recovery_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    organization_id uuid REFERENCES organizations(id) ON DELETE RESTRICT,
    device_id uuid REFERENCES devices(id) ON DELETE RESTRICT,
    recovery_type text NOT NULL CHECK (recovery_type IN ('LOST_DEVICE','ACCOUNT_RECOVERY','DEVICE_REENROLLMENT','OTHER')),
    status text NOT NULL CHECK (status IN ('INITIATED','APPROVED','REJECTED','COMPLETED','EXPIRED','CANCELLED')),
    initiated_at timestamptz NOT NULL DEFAULT now(),
    completed_at timestamptz,
    correlation_id uuid,
    metadata jsonb NOT NULL DEFAULT '{}'
);
CREATE INDEX ix_recovery_user_id ON recovery_events (user_id);
CREATE INDEX ix_recovery_org_id ON recovery_events (organization_id);
CREATE INDEX ix_recovery_device_id ON recovery_events (device_id);
CREATE INDEX ix_recovery_status ON recovery_events (status);
CREATE INDEX ix_recovery_correlation ON recovery_events (correlation_id);

CREATE TABLE security_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type text NOT NULL,
    actor_user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
    organization_id uuid REFERENCES organizations(id) ON DELETE RESTRICT,
    device_id uuid REFERENCES devices(id) ON DELETE RESTRICT,
    session_id uuid REFERENCES sessions(id) ON DELETE RESTRICT,
    resource_type text,
    resource_id uuid,
    result text NOT NULL CHECK (result IN ('SUCCESS','FAILURE','DENIED')),
    correlation_id uuid,
    occurred_at timestamptz NOT NULL DEFAULT now(),
    metadata jsonb NOT NULL DEFAULT '{}'
);
CREATE INDEX ix_security_events_org_time ON security_events (organization_id, occurred_at);
CREATE INDEX ix_security_events_actor_time ON security_events (actor_user_id, occurred_at);
CREATE INDEX ix_security_events_type_time ON security_events (event_type, occurred_at);
CREATE INDEX ix_security_events_correlation ON security_events (correlation_id);

-- Cross-table integrity helpers.
CREATE OR REPLACE FUNCTION swafos_validate_membership_role_scope()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE role_org uuid;
BEGIN
  SELECT organization_id INTO role_org FROM roles WHERE id = NEW.role_id;
  IF role_org IS NOT NULL AND role_org <> NEW.organization_id THEN
    RAISE EXCEPTION 'membership role belongs to a different organization';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER trg_membership_role_scope BEFORE INSERT OR UPDATE OF organization_id, role_id ON organization_memberships
FOR EACH ROW EXECUTE FUNCTION swafos_validate_membership_role_scope();

CREATE OR REPLACE FUNCTION swafos_validate_device_registration_scope()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE device_user uuid;
BEGIN
  SELECT user_id INTO device_user FROM devices WHERE id = NEW.device_id;
  IF device_user IS NULL OR device_user <> NEW.user_id THEN
    RAISE EXCEPTION 'device registration user does not match device owner';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER trg_device_registration_scope BEFORE INSERT OR UPDATE OF device_id, user_id ON device_registrations
FOR EACH ROW EXECUTE FUNCTION swafos_validate_device_registration_scope();

CREATE OR REPLACE FUNCTION swafos_validate_session_device_scope()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE device_user uuid;
BEGIN
  IF NEW.device_id IS NOT NULL THEN
    SELECT user_id INTO device_user FROM devices WHERE id = NEW.device_id;
    IF device_user IS NULL OR device_user <> NEW.user_id THEN
      RAISE EXCEPTION 'session device does not belong to session user';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER trg_session_device_scope BEFORE INSERT OR UPDATE OF device_id, user_id ON sessions
FOR EACH ROW EXECUTE FUNCTION swafos_validate_session_device_scope();

-- Security history is append-oriented. Application runtime receives no UPDATE/DELETE grant.
ALTER TABLE authorization_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE recovery_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_events ENABLE ROW LEVEL SECURITY;

-- Tenant/user-owned tables are RLS-enabled now; policies are added after trusted context exists.
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mfa_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_policies ENABLE ROW LEVEL SECURITY;

COMMIT;