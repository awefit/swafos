# ADR-008 — Profit Allocation Policy

- Status: Accepted
- Date: 2026-09-01
- Depends on: ADR-006, ADR-007

## Decision

SWAFOS will model profit allocation as a configurable, versioned business policy. The reference policy is **30/30/30/10**, applied after eligible business costs have been deducted from gross revenue.

The allocation policy is not hard-coded and is not a statutory accounting rule.

The policy is a **core financial benchmark and planning framework**. It does not require immediate cash distribution.

## Reference Formula

```text
Gross Revenue
  - Eligible Business Costs
  = Distributable Profit

Distributable Profit × Allocation Percentage
  = Target Allocation
```

Reference allocation:

```text
Investor / Owner     30%
Operator / Pelaksana 30%
Growth Allocation    30%
CSR                  10%
                     ───
                    100%
```

## Example

```text
Gross Revenue        Rp100.000.000
Eligible Costs        Rp60.000.000
                     ─────────────
Distributable Profit  Rp40.000.000
```

Target allocation:

```text
Investor / Owner     Rp12.000.000
Operator / Pelaksana Rp12.000.000
Growth Allocation    Rp12.000.000
CSR                   Rp4.000.000
```

## Policy Structure

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

A policy version cannot become active unless its complete allocation rules total exactly 100%.

## Profit Basis

V0.1 supports configurable profit bases, including:

- gross revenue;
- revenue less eligible business costs (reference/default);
- another organization-defined distributable-result formula.

The reference SWAFOS business strategy uses **revenue less eligible business costs**.

The actual basis used by every allocation run must be stored.

## Eligible Business Costs

Eligible costs are operating and economic costs required by the business and approved by its cost policy. Depending on the organization's accounting treatment, these can include:

- production costs;
- labor and operating compensation;
- logistics and distribution;
- marketing and selling costs;
- utilities;
- maintenance;
- platform/transaction fees;
- taxes treated as business expenses;
- depreciation;
- administration;
- other approved operating costs.

Capital contributions are **not** costs. Investor capital is a source of financing. Loans are liabilities and are not revenue or profit.

Asset acquisition is recorded as an asset when appropriate; its economic consumption can subsequently appear through depreciation or other approved treatment.

Debt principal repayment is a cash-flow event and liability reduction, not an operating expense. Interest/financing costs may be an eligible business cost according to the organization's financial policy.

## Allocation vs Cash

SWAFOS must distinguish:

1. **Target allocation** — amount indicated by the policy.
2. **Approved allocation** — amount management/owner authorizes under current conditions.
3. **Committed allocation** — amount reserved for a specific purpose.
4. **Executed distribution/payment** — amount actually settled.
5. **Retained/deferred amount** — amount not yet distributed or deployed.

The 30/30/30/10 framework therefore remains visible even when actual cash movement differs.

Actual distribution must consider:

- available cash;
- operational working-capital requirements;
- taxes and other obligations;
- debt repayment schedule;
- committed payments;
- inventory/production requirements;
- business continuity;
- approved expansion requirements.

## Growth Allocation

Growth Allocation is a target allocation of distributable profit for future business development. It does **not** have to be spent immediately.

It may remain as a Growth Fund until an expansion/reinvestment decision is approved.

Potential uses include:

- additional fish ponds;
- poultry capacity;
- crop expansion;
- equipment;
- irrigation;
- technology;
- trading working capital;
- online business expansion;
- new business experiments;
- strategic growth reserves.

Growth spending must retain source attribution to the allocation period and policy version so SWAFOS can measure whether reinvestment produced additional capacity, revenue, margin, or return.

## Owner / Investor Priority

SWAFOS must support owner/investor priority without forcing a cash distribution that would impair business continuity.

The system therefore separates target entitlement from actual payment. Management may defer, retain, or partially execute an allocation when supported by the organization's financial policy and available cash.

## Allocation Period

Allocation can be calculated:

- daily; or
- monthly.

The organization chooses its operational cadence. Periods can be closed so finalized calculations are not silently changed.

## Allocation Run

An allocation run represents one calculation event for a defined organization/scope and period.

It retains:

- period start/end;
- gross revenue basis;
- eligible cost basis;
- distributable profit;
- policy version;
- calculated target amounts;
- approved amounts where applicable;
- calculation timestamp;
- status;
- approval/finalization metadata where required.

## Allocation Entitlements

An allocation entitlement is the amount assigned to a beneficiary category before actual cash settlement.

Initial categories:

- investor/owner;
- operator/pelaksana;
- growth;
- CSR.

Future organizations may configure additional categories subject to policy validation.

## Policy Versioning

Allocation policies are versioned and effective-dated.

Historical calculations retain the policy version used at calculation time.

## Recalculation and Finalization

Draft allocation runs may be recalculated. Finalized runs must not be overwritten.

Corrections use an explicit adjustment/reversal process:

```text
Original Allocation Run
        ↓
Adjustment / Reversal
        ↓
Replacement Calculation
```

The historical calculation remains auditable.

## Multi-Business Support

An organization may operate several businesses:

```text
Organization
 ├── Fish
 ├── Chicken
 ├── Crop
 ├── Trading
 └── Online
```

Each scope may use the organization default policy or an explicitly assigned policy version.

## Management Metrics

SWAFOS should expose at minimum:

- gross revenue;
- eligible business costs;
- distributable profit;
- target investor allocation;
- target operator allocation;
- target growth allocation;
- target CSR allocation;
- approved allocation;
- growth allocation deployed;
- growth allocation remaining;
- allocation-to-revenue ratio;
- allocation-to-profit ratio;
- cash actually distributed.

The system must make clear whether a metric is calculated, targeted, approved, committed, retained, or paid.

## Strategic Principle

The allocation policy creates a self-reinforcing growth loop:

```text
Revenue
   ↓
Costs
   ↓
Distributable Profit
   ↓
30% Growth Allocation Target
   ↓
Reinvestment when financially appropriate
   ↓
Higher Capacity / New Business
   ↓
Higher Future Revenue
```

This is a core strategic model for the SWAFOS reference business and should be supported by the platform without being hard-coded into the platform.

## Consequences

### Positive

- Preserves the 30/30/30/10 financial philosophy.
- Makes the policy configurable for different businesses.
- Creates an explicit reinvestment engine.
- Separates profit allocation from cash payment.
- Supports daily and monthly operating cadence.
- Enables historical audit of allocation decisions.
- Prevents capital and debt from being misclassified as revenue/profit.

### Negative

- Requires policy versioning.
- Requires clear definition of eligible costs.
- Requires period-closing/recalculation controls.
- Must not be confused with statutory accounting or tax treatment.

## Next Step

Add policy, policy-version, allocation-run, and allocation-entitlement entities to the physical ERD before generating PostgreSQL migrations.
