# ADR-006 — Economic Model

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001 through ADR-005

## Decision

SWAFOS will treat economics as a first-class domain. Operational events may generate economic effects, but revenue, business costs, distributable profit, cash movement, and profit allocation are distinct concepts.

The model must support both management accounting and a configurable business growth policy.

## Economic Flow

```text
Gross Revenue
      ↓
Business Costs
      ↓
Distributable Profit
      ↓
Allocation Policy
      ├── Investor
      ├── Operator / Pelaksana
      ├── Growth Allocation
      └── CSR
```

The allocation policy is applied to the defined distributable profit pool, not directly to gross revenue.

## Distributable Profit

For the SWAFOS reference business policy:

```text
Distributable Profit = Gross Revenue - Eligible Business Costs
```

The exact definition of eligible costs must be explicit for each organization/policy version.

Example:

```text
Gross Revenue       Rp100.000.000
Business Costs       Rp60.000.000
                    ─────────────
Distributable Profit Rp40.000.000
```

The Rp40.000.000 is then allocated according to policy.

## Default Reference Allocation Policy

The initial reference policy is:

```text
Investor            30%
Operator / Pelaksana 30%
Growth Allocation    30%
CSR                  10%
                     ───
                    100%
```

For the example above:

```text
Investor             Rp12.000.000
Operator / Pelaksana Rp12.000.000
Growth Allocation    Rp12.000.000
CSR                   Rp4.000.000
                     ─────────────
                     Rp40.000.000
```

This policy is a configurable business rule, not a hard-coded accounting rule.

## Allocation Policy as Data

SWAFOS must store allocation policies and versions rather than embedding `30/30/30/10` in application code.

Conceptual model:

```text
Allocation Policy
  ├── effective_from
  ├── effective_to
  ├── status
  └── Allocation Rules*
          ├── beneficiary_type
          ├── percentage
          ├── priority/order
          └── destination/scope
```

The sum of active allocation percentages for a policy version must equal 100% before the policy can be activated.

The policy may be applied by organization, business unit, project, or other defined economic scope.

## Growth Allocation

Growth Allocation is a deliberate reinvestment pool intended to expand future earning capacity.

Examples:

- additional fish production capacity
- additional poultry capacity
- crop expansion
- irrigation or pond improvement
- equipment
- technology
- working capital for new trading activity
- online business expansion
- new business experiments

A Growth Allocation transaction should preserve its originating profit period and allocation policy version.

## CSR Allocation

CSR is a deliberate allocation from distributable profit. It is not treated as an operating cost merely because it is a planned distribution.

CSR disbursements should remain traceable to the originating allocation period/policy.

## Investor and Operator Allocation

Investor and Operator/Pelaksana allocations represent distributable-profit entitlements according to the active policy. Their actual cash payment is a separate settlement event.

Therefore:

```text
Profit Allocation
       ≠
Cash Settlement
```

An entitlement may exist before it is paid.

## Revenue

Revenue represents economic value recognized from sales or other defined business activities.

Revenue should retain a source reference to the originating sale or transaction.

## Business Costs

A cost record represents an economic consumption or obligation.

Initial classifications:

- Direct: directly attributable to a production batch, lot, order, or sale.
- Indirect: supports multiple economic units and requires explicit allocation if assigned.
- Capital: creates or improves a durable asset and should not automatically be treated as an ordinary operating cost.

Examples:

- seed
- feed
- fertilizer
- medicine
- labor
- electricity
- fuel
- packaging
- logistics
- processing
- platform fees
- maintenance

## Cost Attribution

Costs should be attributable where evidence exists to:

- organization
- business unit/project
- production unit
- production batch
- lot
- order
- sale
- activity
- asset

Indirect costs require an explicit allocation basis when management reporting assigns them to economic units.

Examples of allocation bases:

- area
- production quantity
- machine hours
- labor hours
- feed quantity
- revenue share
- usage volume

Allocation records must preserve the rule/version used so historical results can be explained.

## Cash

Cash transaction represents actual movement of money in or out of a cash/bank account.

Cash timing may differ from revenue, cost, or profit allocation.

```text
Sale today
Revenue today
Customer pays 14 days later
Cash later
```

## Unit Economics

SWAFOS should calculate economics at the most granular reliable level available.

Examples:

### Aquaculture

```text
Cost per kg = Attributable batch cost / Saleable harvest kg
Margin per kg = Selling price per kg - Attributable cost per kg
```

### Poultry

```text
Cost per bird = Attributable production cost / Saleable birds
```

### Crop

```text
Cost per kg = Attributable crop cost / Saleable harvested kg
```

### Trading

```text
Trading margin = Sale value - Purchase cost - Direct trading costs
```

## Margin Hierarchy

```text
Revenue
 - Direct product cost
 = Gross Margin

Gross Margin
 - Direct operating costs
 = Contribution Margin

Contribution Margin
 - Allocated overhead
 = Operating Result
```

Distributable profit is then calculated according to the organization's approved economic policy and cost boundary. It must not be silently conflated with accounting net income.

## ROI and Capital Efficiency

ROI metrics must specify denominator and time period. SWAFOS should distinguish:

- return on production cost
- return on invested capital
- cash-on-cash return
- payback period
- capital turnover
- growth capital reinvestment rate

No generic `ROI` number should be presented without defining its calculation.

## Working Capital

SWAFOS should expose capital tied up in:

- inventory
- receivables
- advances
- production in progress
- unpaid supplier obligations

This is essential for scaling decisions because profitable operations can still fail through cash-flow constraints.

## Economic Snapshots

Historical reports must be reproducible. If prices, costs, allocation rules, or assumptions change, historical results must not silently change without an explicit recalculation/versioning event.

## Consequences

### Positive

- Business economics become a first-class operating capability.
- The 30/30/30/10 strategy can be automated without hard-coding it.
- Growth Allocation becomes a measurable reinvestment engine.
- Investor, operator, growth, and CSR entitlements remain auditable.
- The Rp500 million target can be monitored from actual business economics.

### Negative

- Cost boundary definitions require discipline.
- Allocation policy changes require versioning.
- Profit allocation is a business policy and should not be confused with formal statutory accounting treatment.

## Next Step

Finalize the open-core licensing choice and extend the V0.1 relational model with allocation-policy and profit-allocation entities before generating the first migration.
