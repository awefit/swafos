# SWAFOS Database Migrations

This directory contains the PostgreSQL schema migrations for SWAFOS.

## V0.1 Migration Order

1. Extensions and shared primitives
2. Organizations and identity boundaries
3. Business actors and locations
4. Production foundations
5. Lots and inventory ledger
6. Commerce
7. Revenue and operating costs
8. Capital sources and transactions
9. Loans and repayment schedules
10. Assets and depreciation
11. Cash ledger
12. Profit allocation policies and runs
13. Growth funds
14. Expansion initiatives and funding plans
15. Audit metadata and integrity indexes

## Rules

- PostgreSQL `NUMERIC` is used for persisted money and measured quantities.
- Financial and inventory history is append-oriented; corrections use reversal/adjustment events.
- Tenant-owned records carry `organization_id`.
- Database constraints enforce structural integrity; application authorization enforces business permissions.
- 30/30/30/10 is seed policy data, not hard-coded schema logic.
- Capital expenditure, loan principal, revenue, cost, profit and cash are separate concepts.
- Migration files must be deterministic and safe to run in dependency order.

## Scope

V0.1 is a management/economic system foundation. It is not a statutory double-entry accounting engine.
