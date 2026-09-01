# ADR-009 — Business Financial Layers & Accounting Boundary

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-006, ADR-008, ERD-V0.1

## Decision

SWAFOS V0.1 will not implement a full general ledger or double-entry accounting engine. Instead, it will provide disciplined business financial ledgers for operations, economics, capital, liabilities, cash, and profit allocation.

The architecture must preserve enough transactional integrity and traceability to support a future accounting module or external accounting integration without rebuilding the business domain.

## Financial Layers

```text
Capital
  ├── Investor / Owner Contributions
  └── Retained Business Capital

Liabilities
  └── Loans / Payables / Other Obligations

Assets
  ├── Production Assets
  ├── Equipment
  ├── Infrastructure
  └── Inventory

Operations
  ├── Revenue
  ├── Eligible Business Costs
  ├── Tax Expense
  └── Depreciation

Economics
  └── Distributable Result

Allocation
  ├── Investor / Owner Target
  ├── Operator Target
  ├── Growth Target
  └── CSR Target

Cash
  ├── Receipts
  ├── Payments
  ├── Debt Service
  └── Actual Distributions
```

## Capital

Investor funding is capital, not revenue and not operating expense.

An asset purchased with investor capital remains an asset of the business according to the applicable ownership/legal arrangement. The source of funding must remain traceable.

## Debt

Borrowed money is a liability. Loan principal repayment reduces the liability and cash balance; it is not an operating expense. Interest or financing charges may be an operating/financial cost according to the applicable policy.

Debt planning must consider:

- operating cash needs;
- production cycle requirements;
- committed obligations;
- growth funding;
- repayment schedule;
- liquidity buffer.

## Assets & Depreciation

Qualifying long-lived assets are recorded as assets. Depreciation represents the economic consumption of depreciable assets and is recognized separately from acquisition cash flow.

SWAFOS must distinguish:

```text
Asset acquisition → Cash outflow + Asset increase
Depreciation       → Economic expense, no immediate cash outflow
Asset disposal     → Asset reduction + cash/result effects
```

## Operating Costs

Eligible business costs reduce the economic result before the allocation policy is applied.

Tax expense and depreciation are included in the economic cost model according to the configured policy.

## Distributable Result

Conceptually:

```text
Gross Revenue
- Eligible Business Costs
= Distributable Result
```

The exact definition of eligible costs must be policy-driven and auditable. Capital expenditure is not automatically an operating cost merely because it creates a cash outflow.

## Allocation

The allocation engine calculates target allocations from the distributable result using the active versioned policy. It does not automatically imply cash payment.

The system distinguishes:

- target allocation;
- approved allocation;
- committed allocation;
- executed distribution;
- deferred amount;
- retained amount.

## Cash Flow Priority

When available cash is insufficient to execute all target allocations, SWAFOS must expose the shortfall rather than silently altering the policy.

Management/owner decisions may prioritize:

1. business continuity and mandatory obligations;
2. owner/investor requirements;
3. debt obligations according to approved schedule;
4. growth and expansion;
5. discretionary distributions.

The exact priority is configurable by organization policy; the system must retain the decision and reason.

## Expansion

Expansion spending funded from Growth Allocation is tracked separately from the original profit allocation.

The system should retain the chain:

```text
Distributable Result
 → Growth Allocation
 → Growth Fund
 → Expansion Decision
 → Funding
 → Asset / Capacity
 → Incremental Economic Result
```

This enables ROI and payback analysis later.

## Accounting Boundary

V0.1 deliberately excludes:

- full chart of accounts;
- journal-entry engine;
- double-entry posting;
- trial balance;
- statutory financial statements;
- jurisdiction-specific tax accounting.

Those capabilities may be added later or integrated with an accounting platform.

## Future Compatibility

All material economic events must have stable identifiers, timestamps, source references, amounts, currencies, and audit history so a future accounting adapter can translate them into journal entries.

## Consequences

### Positive

- Faster path to operational value.
- Clear distinction between economics and accounting.
- Less V0.1 complexity.
- Strong foundation for cash-flow and growth intelligence.

### Negative

- SWAFOS V0.1 is not a statutory accounting replacement.
- Some financial reports will remain management reports rather than formal accounting statements.
