# ADR-010 — Expansion Financing & Optional Delivery Capability

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-008, ADR-009, SCHEMA-CONSISTENCY-REVIEW-V0.1

## Decision

SWAFOS will treat business expansion as an explicit decision process rather than an automatic use of Growth Allocation.

An expansion may be funded through:

- Growth Fund;
- existing business cash;
- new investor/owner capital;
- financing/loan;
- or a combination.

The selected funding plan must be evaluated against business continuity, working-capital requirements, existing obligations, debt capacity, expected return, and strategic value.

## Expansion Model

```text
Expansion Opportunity
        ↓
Expansion Initiative
        ↓
Funding Requirement
        ↓
Funding Options
        ├── Growth Fund
        ├── Existing Cash
        ├── Investor Capital
        ├── Financing
        └── Combination
        ↓
Financing Decision
        ↓
Funding Plan
        ↓
Asset / Capacity / New Business
        ↓
Performance Measurement
```

## Example

For a Rp20,000,000 land acquisition, SWAFOS must not assume that cash purchase is automatically optimal merely because the Growth Fund contains Rp20,000,000.

The system should be capable of comparing:

- full cash purchase;
- down payment plus installments;
- financing;
- partial cash + financing;
- deferred purchase.

The comparison should consider liquidity after the transaction, working-capital needs, scheduled obligations, debt service, and expected expansion economics.

## Growth Allocation Rule

Growth Allocation remains a financial entitlement/target and may be retained in the Growth Fund. It does not need to be spent immediately.

Expansion is approved only when the owner/management determines that the business can support it under the applicable financial policy.

## Financing Decision Record

The eventual domain model should preserve:

- expansion objective;
- requested amount;
- selected funding sources;
- payment schedule;
- cash-flow impact;
- expected operating impact;
- expected revenue/profit impact;
- risk assessment;
- decision status;
- decision maker;
- decision date;
- rationale.

## Delivery Capability

SWAFOS will recognize Delivery as an optional business capability, not a mandatory part of the V0.1 farm/production core.

Delivery has two potential modes:

```text
INTERNAL
Business → Customer

EXTERNAL
Third Party → Customer
```

Internal delivery supports fulfillment. External delivery may become an additional revenue stream when utilization and economics justify it.

## Delivery Architecture Boundary

The core domain may reserve extension points for:

- delivery orders;
- routes;
- vehicles;
- drivers/operators;
- delivery status;
- delivery costs;
- delivery revenue;
- delivery performance.

Detailed logistics operations are deferred until the business case warrants implementation.

## Asset Economics

A vehicle or other delivery asset can function as both:

- an operational cost/capacity resource for internal fulfillment;
- a revenue-generating asset for external delivery services.

SWAFOS should therefore support future unit economics such as:

- cost per kilometer;
- cost per delivery;
- revenue per delivery;
- margin per delivery;
- utilization rate;
- revenue per hour;
- break-even utilization;
- payback period.

## Consequences

### Positive

- Growth capital remains flexible.
- Expansion decisions become cash-flow aware.
- Financing choices are auditable.
- Future delivery revenue can be added without redesigning the core.
- SWAFOS can compare competing uses of Growth Fund.

### Negative

- Expansion decision support is more complex than simple expense tracking.
- Detailed logistics capabilities must remain deferred to prevent scope expansion too early.
