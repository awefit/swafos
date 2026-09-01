-- SWAFOS V0.1
-- 0003_database_roles_and_grants.sql
-- Privilege grants assume the database roles are provisioned by infrastructure.
-- Role creation and credentials are intentionally NOT stored in this migration.

BEGIN;

-- Remove default public access from application schemas/objects where relevant.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA app FROM PUBLIC;

-- The runtime may use the public tables, but it cannot change schema objects.
GRANT USAGE ON SCHEMA public TO application_runtime;
GRANT USAGE ON SCHEMA app TO application_runtime;

GRANT SELECT, INSERT, UPDATE ON
    organizations,
    users,
    organization_memberships,
    business_actors,
    locations
TO application_runtime;

GRANT SELECT ON
    app.roles,
    app.permissions,
    app.role_permissions,
    app.membership_roles
TO application_runtime;

GRANT EXECUTE ON FUNCTION
    app.current_organization_id(),
    app.current_user_id(),
    app.current_membership_id(),
    app.has_permission(TEXT)
TO application_runtime;

-- Reporting is read-only. RLS remains the tenant isolation mechanism.
GRANT USAGE ON SCHEMA public TO readonly_reporting;
GRANT SELECT ON
    organizations,
    users,
    organization_memberships,
    business_actors,
    locations
TO readonly_reporting;

GRANT USAGE ON SCHEMA app TO readonly_reporting;
GRANT SELECT ON
    app.roles,
    app.permissions,
    app.role_permissions,
    app.membership_roles
TO readonly_reporting;

GRANT EXECUTE ON FUNCTION
    app.current_organization_id(),
    app.current_user_id(),
    app.current_membership_id()
TO readonly_reporting;

-- Background worker has the same foundation access as runtime for now,
-- but remains a separate identity so its grants can be narrowed later.
GRANT USAGE ON SCHEMA public TO background_worker;
GRANT USAGE ON SCHEMA app TO background_worker;
GRANT SELECT, INSERT, UPDATE ON
    organizations,
    users,
    organization_memberships,
    business_actors,
    locations
TO background_worker;
GRANT SELECT ON
    app.roles,
    app.permissions,
    app.role_permissions,
    app.membership_roles
TO background_worker;
GRANT EXECUTE ON FUNCTION
    app.current_organization_id(),
    app.current_user_id(),
    app.current_membership_id(),
    app.has_permission(TEXT)
TO background_worker;

-- Migration authority owns/changes schema through the deployment process.
-- It is intentionally absent from normal runtime grants.

-- Platform operations is also intentionally not granted ordinary tenant data
-- access here. Infrastructure privileges are managed separately.

-- No application-facing role may bypass RLS.
-- BYPASSRLS, SUPERUSER, ownership and DDL privileges must be absent from
-- application_runtime, readonly_reporting and background_worker.

COMMIT;
