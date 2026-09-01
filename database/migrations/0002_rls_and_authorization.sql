-- SWAFOS V0.1
-- 0002_rls_and_authorization.sql
-- Security foundation for the tables created by 0001.

BEGIN;

CREATE SCHEMA IF NOT EXISTS app;

CREATE TABLE app.roles (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    is_system_role BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE app.permissions (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE app.role_permissions (
    role_code TEXT NOT NULL REFERENCES app.roles(code) ON DELETE CASCADE,
    permission_code TEXT NOT NULL REFERENCES app.permissions(code) ON DELETE CASCADE,
    PRIMARY KEY (role_code, permission_code)
);

CREATE TABLE app.membership_roles (
    membership_id UUID NOT NULL REFERENCES organization_memberships(id) ON DELETE CASCADE,
    role_code TEXT NOT NULL REFERENCES app.roles(code),
    PRIMARY KEY (membership_id, role_code)
);

INSERT INTO app.roles (code, name, description, is_system_role) VALUES
    ('owner', 'Owner', 'Business owner within an organization', TRUE),
    ('manager', 'Manager', 'Operational manager', TRUE),
    ('finance', 'Finance', 'Financial operations role', TRUE),
    ('operator', 'Operator', 'General operational role', TRUE),
    ('farm_manager', 'Farm Manager', 'Production management role', TRUE),
    ('seller', 'Seller', 'Sales and customer operations role', TRUE),
    ('collector', 'Collector', 'Collection and aggregation role', TRUE),
    ('warehouse', 'Warehouse', 'Inventory and warehouse role', TRUE),
    ('delivery', 'Delivery', 'Delivery operations role', TRUE),
    ('auditor', 'Auditor', 'Read-only audit role', TRUE),
    ('investor', 'Investor', 'Restricted investor-facing role', TRUE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO app.permissions (code, name, description) VALUES
    ('organization.read', 'Read organization', 'Read permitted organization data'),
    ('organization.manage_members', 'Manage members', 'Manage organization membership'),
    ('production.read', 'Read production', 'Read production records'),
    ('production.create', 'Create production', 'Create production records'),
    ('inventory.read', 'Read inventory', 'Read inventory records'),
    ('inventory.create_movement', 'Create inventory movement', 'Create inventory movements'),
    ('sales.read', 'Read sales', 'Read sales records'),
    ('sales.create', 'Create sales', 'Create sales records'),
    ('finance.read', 'Read finance', 'Read permitted financial records'),
    ('finance.create', 'Create finance', 'Create permitted financial records'),
    ('finance.adjust', 'Adjust finance', 'Request or post authorized financial adjustments'),
    ('allocation.calculate', 'Calculate allocation', 'Calculate allocation runs'),
    ('allocation.approve', 'Approve allocation', 'Approve allocation runs'),
    ('allocation.execute', 'Execute allocation', 'Execute approved allocations'),
    ('capital.read', 'Read capital', 'Read permitted capital records'),
    ('capital.manage', 'Manage capital', 'Manage authorized capital records'),
    ('expansion.create', 'Create expansion', 'Create expansion initiatives'),
    ('expansion.approve', 'Approve expansion', 'Approve expansion initiatives'),
    ('expansion.execute', 'Execute expansion', 'Execute approved expansion funding'),
    ('audit.read', 'Read audit', 'Read permitted audit history')
ON CONFLICT (code) DO NOTHING;

-- Owner role is intentionally broad within its organization, not a platform role.
INSERT INTO app.role_permissions (role_code, permission_code)
SELECT 'owner', code FROM app.permissions
ON CONFLICT DO NOTHING;

INSERT INTO app.role_permissions (role_code, permission_code) VALUES
    ('manager', 'organization.read'),
    ('manager', 'production.read'),
    ('manager', 'production.create'),
    ('manager', 'inventory.read'),
    ('manager', 'inventory.create_movement'),
    ('manager', 'sales.read'),
    ('manager', 'sales.create'),
    ('finance', 'organization.read'),
    ('finance', 'finance.read'),
    ('finance', 'finance.create'),
    ('finance', 'finance.adjust'),
    ('finance', 'allocation.calculate'),
    ('finance', 'capital.read'),
    ('finance', 'audit.read'),
    ('operator', 'organization.read'),
    ('operator', 'production.read'),
    ('operator', 'production.create'),
    ('operator', 'inventory.read'),
    ('operator', 'inventory.create_movement'),
    ('farm_manager', 'organization.read'),
    ('farm_manager', 'production.read'),
    ('farm_manager', 'production.create'),
    ('farm_manager', 'inventory.read'),
    ('farm_manager', 'inventory.create_movement'),
    ('seller', 'organization.read'),
    ('seller', 'inventory.read'),
    ('seller', 'sales.read'),
    ('seller', 'sales.create'),
    ('collector', 'organization.read'),
    ('collector', 'inventory.read'),
    ('collector', 'inventory.create_movement'),
    ('warehouse', 'organization.read'),
    ('warehouse', 'inventory.read'),
    ('warehouse', 'inventory.create_movement'),
    ('delivery', 'organization.read'),
    ('auditor', 'organization.read'),
    ('auditor', 'audit.read'),
    ('investor', 'organization.read'),
    ('investor', 'capital.read')
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION app.current_organization_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('app.organization_id', true), '')::UUID
$$;

CREATE OR REPLACE FUNCTION app.current_user_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('app.user_id', true), '')::UUID
$$;

CREATE OR REPLACE FUNCTION app.current_membership_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('app.membership_id', true), '')::UUID
$$;

CREATE OR REPLACE FUNCTION app.has_permission(permission_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = app, public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM app.membership_roles mr
        JOIN app.role_permissions rp ON rp.role_code = mr.role_code
        WHERE mr.membership_id = app.current_membership_id()
          AND rp.permission_code = $1
    )
    AND EXISTS (
        SELECT 1
        FROM public.organization_memberships om
        WHERE om.id = app.current_membership_id()
          AND om.organization_id = app.current_organization_id()
          AND om.user_id = app.current_user_id()
          AND om.status = 'active'
    )
$$;

ALTER TABLE business_actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY business_actors_tenant_isolation
ON business_actors
USING (organization_id = app.current_organization_id())
WITH CHECK (organization_id = app.current_organization_id());

CREATE POLICY locations_tenant_isolation
ON locations
USING (organization_id = app.current_organization_id())
WITH CHECK (organization_id = app.current_organization_id());

CREATE POLICY memberships_tenant_isolation
ON organization_memberships
USING (organization_id = app.current_organization_id())
WITH CHECK (organization_id = app.current_organization_id());

-- The application must use controlled database roles. Tenant-facing roles must not
-- receive BYPASSRLS or ownership privileges. Exact grants are deployment-specific.

COMMIT;
