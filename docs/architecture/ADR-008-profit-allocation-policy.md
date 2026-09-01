# ADR-008 — Profit Allocation Policy

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-006, ADR-007

## Decision

SWAFOS will model profit allocation as a configurable, versioned business policy. The reference policy is **30/30/30/10**, applied only after eligible business costs have been deducted from gross revenue.

The allocation policy is not hard-coded and is not a statutory accounting rule.

## Reference Formula

```text
Gross Revenue
  - Eligible Business Costs
  = Distributable Profit

Distributable Profit × Allocation Percentage
  = Allocation Entitlement
```

Reference allocation:

```text
Investor             30%
Operator / Pelaksana 30%
Growth Allocation    30%
CSR                  10%
                     ───
                    100%
```

## Example

```text
Gross Revenue       Rp100.000.000
Eligible Costs       Rp60.000.000
                    ─────────────
Distributable Profit Rp40.000.000
```

Allocation:

```text
Investor             Rp12.000.000
Operator / Pelaksana Rp12.000.000
Growth Allocation    Rp12.000.000
CSR                   Rp4.000.000
```

## Policy Structure

Conceptually:

```text
Profit Allocation Policy
  └── Policy Version
       ├── Effective Period
       ├── Profit Basis
       └── Allocation Rules*
            ├── Beneficiary Type
            ├── Percentage
            ├── Destination
            └── Priority
```

A policy version cannot become active unless its allocation rules total exactly 100%.

## Profit Basis

The policy must explicitly identify the calculation basis. V0.1 supports:

- gross revenue;
- revenue less eligible business costs (reference/default);
- another organization-defined distributable-result formula.

The reference SWAFOS business strategy uses **revenue less eligible business costs**.

The system must retain the actual basis used for every allocation run.

## Allocation Period

Allocation can be calculated:

- daily; or
- monthly.

The organization chooses its operational cadence. The system should also support closing a period so that finalized allocation results are not silently changed.

## Allocation Run

An allocation run represents one calculation event for a defined organization/scope and period.

It should retain:

- period start/end;
- gross revenue basis;
- eligible cost basis;
- distributable profit;
- policy version;
- calculated allocation amounts;
- calculation timestamp;
- status;
- approval/finalization metadata where required.

## Allocation Entitlements

An allocation entitlement is the amount assigned to a beneficiary category before actual cash settlement.

Initial beneficiary categories:

- investor
- operator
- growth
- CSR

Future organizations may configure additional categories subject to policy validation.

## Growth Allocation as Capital Engine

Growth allocation should be tracked separately from ordinary operating expenditure because it represents deliberate reinvestment of distributable profit.

A growth allocation can be committed to an expansion initiative such as:

- additional fish ponds
- poultry capacity
- crop expansion
- equipment
- irrigation
- technology
- trading working capital
- online business expansion
- new business experiments

The allocation should retain a link to its source period and policy version.

## Settlement Separation

Allocation entitlement and payment are separate records.

```text
Allocation Entitlement
        ↓
     Payable / Commitment
        ↓
      Settlement
```

This prevents cash timing from corrupting profitability reporting.

## Recalculation and Finalization

Draft allocation runs may be recalculated. Finalized runs must not be overwritten.

If a correction is necessary:

```text
Original Allocation Run
        ↓
Adjustment / Reversal
        ↓
Replacement Calculation
```

The historical calculation remains auditable.

## Multi-Business Support

The same organization may run several businesses:

```text
Organization
 ├── Fish
 ├── Chicken
 ├── Crop
 ├── Trading
 └── Online
```

Each business/scope may use the organization's default policy or an explicitly assigned policy version.

This allows the reference 30/30/30/10 policy to remain the default while supporting future negotiated arrangements.

## Management Metrics

SWAFOS should expose at minimum:

- gross revenue
- eligible business costs
- distributable profit
- investor allocation
- operator allocation
- growth allocation
- CSR allocation
- growth allocation deployed
- growth allocation remaining
- allocation-to-revenue ratio
- allocation-to-profit ratio

The system should make clear whether a metric is actual, allocated, committed, or paid.

## Strategic Principle

The allocation policy is designed to create a self-reinforcing growth loop:

```text
Revenue
   ↓
Costs
   ↓
Distributable Profit
   ↓
30% Growth Allocation
   ↓
Reinvestment
   ↓
Higher Capacity / New Business
   ↓
Higher Future Revenue
```

This is a core strategic model for the SWAFOS reference business and should be supported by the platform without being hard-coded into the platform.

## Consequences

### Positive

- Preserves the owner's 30/30/30/10 operating philosophy.
- Makes the rule configurable for different businesses.
- Creates an explicit reinvestment engine.
- Separates profit allocation from cash payment.
- Supports daily and monthly operating cadence.
- Enables historical audit of allocation decisions.

### Negative

- Requires policy versioning.
- Requires clear definition of eligible costs.
- Requires period-closing/recalculation controls.
- Must not be confused with statutory accounting or tax treatment.

## Next Step

Add policy, policy-version, allocation-run, and allocation-entitlement entities to the physical ERD before generating PostgreSQL migrations.
