# SWAFOS Schema Consistency Review V0.1

- Status: Accepted for migration planning
- Date: 2026-09-01

## Objective

Validate that the operational, inventory, commerce, economic, capital, cash, and allocation domains can coexist without creating a foundation that requires structural rework in the next phase.

## Review Result

**PASS with implementation constraints.**

The V0.1 model is suitable for PostgreSQL migration provided the constraints below are enforced at database and application boundaries.

## 1. Tenant Isolation

Every tenant-owned transactional table must carry `organization_id` and enforce tenant isolation at the database boundary. Application authorization remains mandatory for business-role permissions.

Reference/master data that is globally immutable may be shared; business data must not rely on application filtering alone.

## 2. Identity & Authorization Boundary

Users, organization memberships, and business actors remain separate concepts.

- User = authenticated identity.
- Membership = authorization within an organization.
- Business Actor = economic participant such as owner, investor, operator, customer, supplier, collector, or partner.

A user may represent or operate for a business actor, but the two concepts must not be merged.

## 3. Production → Inventory → Commerce → Finance

The canonical business flow is:

```text
Production Activity
    ↓
Harvest / Output
    ↓
Lot
    ↓
Inventory Movement
    ↓
Allocation / Fulfillment
    ↓
Sale
    ↓
Revenue
    ↓
Costs
    ↓
Distributable Result
    ↓
Allocation Policy
```

No downstream financial record should silently create a production or inventory event. Source references must remain traceable.

## 4. Inventory Source of Truth

Inventory movements are authoritative. Derived balances must be reconstructable from movements.

Lot lineage must support split, merge, transformation, and traceability without deleting historical lots.

## 5. Revenue vs Cash

Revenue recognition and cash receipt are separate events.

```text
Sale / Revenue
      ≠
Cash Receipt
```

Receivables can therefore exist without falsely inflating available cash.

## 6. Capital vs Revenue

Investor/owner contributions are capital events, never revenue.

Loan proceeds are liability/cash events, never revenue.

Asset acquisition is an asset/cash event and is not automatically an operating cost.

## 7. Assets & Depreciation

Long-lived assets have their own lifecycle.

```text
Acquisition
  ↓
Asset
  ↓
Depreciation Entries
  ↓
Disposal / Retirement
```

Depreciation is a non-cash economic cost and must not create a duplicate cash payment.

## 8. Costs & Distributable Result

The economic engine calculates a distributable result from recognized gross revenue less policy-eligible business costs.

Capital expenditure must not be deducted merely because it is a cash outflow.

Tax expense and depreciation are represented explicitly in the cost model according to organization policy.

The final eligibility rules must be configurable and auditable.

## 9. Profit Allocation

Allocation policies are versioned and effective-dated.

The reference policy is:

```text
Investor / Owner    30%
Operator / Executor 30%
Growth Allocation   30%
CSR                 10%
```

The policy is a financial benchmark, not an automatic cash-distribution instruction.

The system distinguishes:

```text
Target
  ↓
Approved
  ↓
Committed
  ↓
Executed
```

Deferred or retained allocations remain visible.

## 10. Growth Fund

Growth Allocation can remain retained until an approved deployment occurs.

The system must preserve:

```text
Profit
 → Growth Allocation
 → Growth Fund
 → Expansion Funding
 → Asset / Capacity
```

This enables future ROI, payback, and growth attribution.

## 11. Cash Flow

Cash is an independent dimension from accounting/economic result.

The system must support the distinction between:

- profit without cash;
- cash without profit;
- capital inflow;
- loan inflow;
- operating receipts;
- operating payments;
- principal repayment;
- actual distributions.

## 12. Debt

Loan principal repayment reduces liability and cash. It is not an operating expense.

Interest/financing cost is separately identifiable.

Debt service planning must be visible against operational working-capital and growth requirements.

## 13. Immutability & Audit

Historical financial, inventory, production, and allocation events must not be destructively edited or deleted after posting.

Corrections use explicit reversal/adjustment events.

Every material event requires:

- stable identifier;
- organization identifier;
- timestamp/effective date;
- amount and currency where applicable;
- source/reference identifier where applicable;
- audit metadata.

## 14. Precision

Money and quantities use PostgreSQL `NUMERIC`, never floating-point types for persisted business values.

Currency and unit-of-measure are explicit.

## 15. PostgreSQL Boundary

The migration should enforce:

- primary keys;
- foreign keys;
- unique constraints within organization scope;
- non-negative constraints where semantically valid;
- percentage range constraints;
- allocation total = 100% validation at policy approval/application layer, with database support where practical;
- timestamps;
- status checks/enums where stable;
- indexes on organization and high-volume reference columns.

## 16. Avoided Technical Debt

The following patterns are explicitly prohibited in the core schema:

- generic JSON as the primary storage for core financial transactions;
- floating-point money;
- hard-coded 30/30/30/10 business logic;
- mutable inventory balances without movement history;
- destructive financial transaction deletion;
- treating loans as revenue;
- treating investor capital as revenue;
- treating all cash outflows as costs;
- coupling production records directly to a future accounting chart of accounts.

## 17. Migration Readiness

The schema is approved to proceed to PostgreSQL migration V0.1.

The migration must be staged in dependency order and include rollback-safe structure. Seed/reference data must be separated from business transactions.

## 18. Remaining Non-Blocking Decisions

These can be resolved during implementation without changing the core architecture:

- exact PostgreSQL enum vs lookup-table choices;
- UUID generation strategy;
- API framework;
- job/queue implementation;
- authentication provider;
- detailed tax jurisdiction rules;
- detailed accounting integration mapping.

## Conclusion

The V0.1 domain model is internally consistent enough to implement. Future accounting, advanced analytics, AI, marketplace, and commercial modules can be added without replacing the core economic model.
