# ADR-009 — Capital, Cash & Expansion Model

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-006 and ADR-008

## Decision

SWAFOS will explicitly separate financing sources, assets, operating economics, profit allocation, and cash flow.

```text
Capital Source ≠ Asset ≠ Expense ≠ Revenue ≠ Profit ≠ Cash ≠ Liability
```

## Financing Sources

Initial and subsequent financing may come from:

- investor/owner capital;
- retained business cash;
- loans/debt;
- other explicitly classified financing sources.

Investor capital is financing/equity-like capital and is not revenue or operating cost.

Loan proceeds are liabilities and are not revenue or profit.

## Assets

Business assets may be acquired using investor capital, retained cash, or financing.

Examples:

- ponds;
- poultry facilities;
- agricultural infrastructure;
- machinery;
- vehicles;
- equipment;
- technology infrastructure.

An asset acquisition is not automatically an operating expense. The economic consumption of qualifying assets is represented through depreciation or another approved accounting treatment.

## Debt

Debt repayment is modeled separately from operating cost.

```text
Loan Proceeds
   ↓
Cash + Liability
   ↓
Principal Repayment → Cash decreases + Liability decreases
Interest / Financing Cost → Expense according to policy
```

Repayment planning must consider:

- operating cash requirements;
- working capital;
- committed obligations;
- growth capacity;
- debt maturity and schedule.

SWAFOS should not recommend a repayment action solely from the existence of available cash.

## Operating Economics

The business result is derived from revenue and eligible business costs.

```text
Gross Revenue
 - Eligible Business Costs
 = Distributable Profit
```

Taxes treated as business expenses and depreciation are included according to the organization's cost policy.

## Profit Allocation

Distributable profit generates a target allocation according to the active policy. The reference policy is 30/30/30/10, but actual payment is subject to cash and business conditions.

## Cash Flow

Cash flow tracks actual movement of money independently from profit.

SWAFOS must distinguish:

- operating cash flow;
- financing cash flow;
- investing/asset cash flow;
- actual distributions;
- debt service;
- retained growth funds.

The first implementation may provide a simplified cash-flow classification while preserving the underlying transaction distinctions.

## Expansion

Expansion is a decision, not an automatic expense category.

A Growth Allocation may be:

```text
Targeted
   ↓
Retained in Growth Fund
   ↓
Evaluated
   ↓
Approved Expansion
   ↓
Cash Deployment
   ↓
Asset / Capacity / Working Capital
```

Expansion decisions should consider:

- available cash;
- expected incremental revenue;
- expected incremental margin;
- payback period;
- capital requirement;
- operational capacity;
- risk;
- existing debt obligations;
- strategic priority.

## Owner/Investor Priority

Owner/investor interests are considered before discretionary expansion. However, protecting the continuity and productive capacity of the business is also a core requirement.

The system should expose the trade-off rather than silently make the decision.

Example decision view:

```text
Available Cash                 Rp100m
Required Working Capital        Rp40m
Debt Due                         Rp20m
Committed Obligations            Rp10m
Minimum Cash Reserve              Rp15m
--------------------------------------
Discretionary Capacity            Rp15m
```

This is a planning view, not an automatic payment rule.

## Growth Fund

Growth Allocation should have its own balance and transaction history.

The fund may be:

- retained;
- committed;
- deployed;
- released back to available growth capacity when a commitment is cancelled;
- reallocated through an auditable approval/adjustment.

## Capital Efficiency

SWAFOS should connect expansion spending to subsequent outcomes where possible:

```text
Growth Investment
      ↓
Capacity Added
      ↓
Production / Sales Increase
      ↓
Incremental Revenue
      ↓
Incremental Profit
      ↓
Return / Payback
```

This enables management to distinguish productive growth from spending that does not generate expected returns.

## Consequences

- Financial reports become more meaningful because cash and profit are not conflated.
- Debt repayment can be planned without corrupting operating profitability.
- Expansion can be evaluated as a capital allocation decision.
- Growth Allocation becomes measurable as a reinvestment engine.
- Investor/owner priorities remain visible without hard-coding a forced distribution.

## Next Step

Extend the ERD with policy and capital/cash-flow entities, then perform the final V0.1 schema review before generating migrations.
