# ADR-010 — SWAFOS as a Business Growth Operating System

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-008, ADR-009, SCHEMA-CONSISTENCY-REVIEW-V0.1

## Decision

SWAFOS is defined as a **Business Growth Operating System (BGOS)** rather than only a Business Management System or Farm Management System.

The core system must not merely record historical business activity. It must connect operational performance, financial outcomes, capital allocation, and expansion decisions into a continuous growth loop.

## Growth Loop

```text
Operate
  ↓
Measure
  ↓
Understand Economics
  ↓
Allocate Result
  ↓
Build Growth Fund
  ↓
Evaluate Opportunities
  ↓
Choose Funding / Financing
  ↓
Expand or Reinvest
  ↓
Increase Capacity
  ↓
Operate
```

## Financial Discipline

The reference financial framework is:

```text
Distributable Result
        ↓
30% Investor / Owner
30% Operator / Executor
30% Growth Allocation
10% CSR
```

This remains a configurable policy and financial benchmark. Actual cash deployment is constrained by business continuity, liquidity, obligations, owner decisions, and approved plans.

## Expansion Opportunity

Expansion is modeled as an opportunity that can be evaluated before commitment.

An opportunity may include:

- land acquisition;
- production capacity;
- new production units;
- equipment;
- processing;
- new business lines;
- service businesses;
- delivery capability;
- technology investments;
- market expansion.

An expansion opportunity is not automatically an approved expense or cash transaction.

## Funding vs Financing

SWAFOS must distinguish:

**Funding source** — where capital comes from.

Examples:

- Growth Fund;
- existing business cash;
- investor/owner capital;
- retained business capital;
- loan/financing.

**Financing decision** — how the expansion is paid for.

Examples:

- cash purchase;
- installment/term payment;
- financing;
- mixed funding.

## Expansion Decision Model

Before an expansion is approved, SWAFOS should be able to evaluate:

```text
Purchase / Investment Requirement
        ↓
Available Growth Fund
        ↓
Operating Cash Requirement
        ↓
Working Capital Buffer
        ↓
Existing Obligations
        ↓
Debt Service
        ↓
Expected Revenue / Savings
        ↓
Expected Incremental Costs
        ↓
Expected Return / Payback
        ↓
Risk & Strategic Value
        ↓
Financing Options
        ↓
Expansion Decision
```

The purpose is not to automatically make the decision. The purpose is to prevent a growth decision from being evaluated only on whether the business currently has enough cash to buy the asset.

## Example — Land Acquisition

For a land opportunity valued at Rp20,000,000, SWAFOS should support at least:

```text
Option A — Cash
Rp20m paid now

Option B — Installment
Down payment + scheduled installments

Option C — Mixed
Growth Fund + other approved funding
```

The system compares the liquidity and obligation consequences of each option before execution.

## Business Continuity Constraint

A growth investment must not be evaluated solely by available acquisition cash.

The system should consider a configurable minimum liquidity/working-capital requirement and surface a warning when an expansion would put business continuity at risk.

The system does not silently override an approved financial policy. It records warnings, decisions, approvals, and exceptions.

## Delivery Capability

Delivery is an optional future business capability, not a mandatory V0.1 core feature.

The architecture should remain extensible for:

```text
Internal Delivery
Farm / Seller → Customer

External Delivery
Third Party → Customer
```

When economically justified, delivery assets and capacity can become a revenue-generating business line rather than merely an operating cost.

Potential delivery economics include:

- cost per km;
- cost per trip;
- cost per hour;
- vehicle utilization;
- delivery revenue;
- delivery margin;
- break-even utilization;
- route economics.

Delivery should be activated as a module/capability without changing the core financial model.

## Product Boundary

SWAFOS Core prioritizes the capabilities required to run and grow a business. Optional expansion capabilities should integrate through stable domain contracts rather than forcing unrelated operational complexity into the core.

## Consequences

### Positive

- SWAFOS becomes useful for decision-making, not only record keeping.
- Growth capital remains visible and traceable.
- Expansion can be evaluated economically before cash is committed.
- Multiple business types can use the same financial engine.
- Future capabilities such as delivery can become additional revenue engines.

### Negative

- Decision support is more complex than simple bookkeeping.
- Financial assumptions and policies must be explicit.
- Some recommendations require forecasts and data quality that V0.1 will not yet provide.

## V0.1 Boundary

V0.1 will implement the data foundation for growth intelligence but will not attempt to provide fully automated investment decisions or AI optimization.
