# ADR-006 — Economic Model

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001 through ADR-005

## Decision

SWAFOS will treat economics as a first-class domain. Operational events may generate economic effects, but cash movement, revenue recognition, cost attribution, and profitability are distinct concepts.

The model is designed to answer both operational and management questions:

- What did this activity cost?
- What did this batch/lot/order earn?
- What is the contribution margin?
- Where is capital tied up?
- How quickly does capital return?
- Which production or trading activity should be scaled?

## Economic Flow

```text
Capital
  ↓
Inputs / Assets / Operations
  ↓
Production or Trading
  ↓
Inventory / Lots
  ↓
Sale
  ↓
Revenue
  ↓
Direct + Allocated Costs
  ↓
Contribution / Operating Result
  ↓
Cash + Capital Return
```

## Core Economic Records

### Cost

A cost record represents an economic consumption or obligation.

A cost may be attributable to:

- organization
- farm
- production unit
- production batch
- lot
- order
- sale
- asset
- activity
- other defined scope

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
- depreciation/allocation where enabled

### Revenue

Revenue represents economic value recognized from sales or other defined business activities.

Revenue should retain a source reference to the originating sale or transaction.

### Cash Transaction

Cash transaction represents movement of money in or out of a cash/bank account.

Cash timing may differ from revenue or cost recognition.

```text
Sale today
Revenue today
Customer pays 14 days later
Cash later
```

## Cost Classification

Initial classification:

- Direct: directly attributable to a production batch, lot, order, or sale.
- Indirect: supports multiple economic units and requires allocation if assigned.
- Capital: creates or improves a durable asset and should not be treated as an ordinary period operating cost at acquisition.

## Cost Allocation

Allocation must be explicit and reproducible.

Examples of allocation bases:

- area
- production quantity
- machine hours
- labor hours
- feed quantity
- revenue share
- headcount
- usage volume

An allocation record must preserve the allocation rule/basis used so historical results can be explained.

## Unit Economics

SWAFOS should calculate economics at the most granular reliable level available.

Examples:

### Aquaculture

```text
Cost per kg = Total attributable batch cost / Harvest kg
Gross margin per kg = Selling price per kg - Cost per kg
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
 - COGS / direct product cost
 = Gross Margin

Gross Margin
 - Direct operating costs
 = Contribution Margin

Contribution Margin
 - Allocated operating overhead
 = Operating Result
```

Exact accounting treatment may later be extended by a dedicated accounting module. The core economic model must remain understandable and auditable.

## ROI and Capital Efficiency

ROI metrics must specify the denominator and time period. SWAFOS should distinguish:

- return on production cost
- return on invested capital
- cash-on-cash return
- payback period
- capital turnover

No single generic `ROI` number should be presented without defining its calculation.

## Working Capital

The system should be able to expose capital tied up in:

- inventory
- receivables
- advances
- production in progress
- unpaid supplier obligations

This is essential for scaling decisions because profitable operations can still fail through cash-flow constraints.

## Economic Attribution

A traceable economic chain should be possible where source data exists:

```text
Purchase
  ↓
Inventory Movement
  ↓
Batch Activity / Lot
  ↓
Cost
  ↓
Harvest / Trading Output
  ↓
Sale
  ↓
Revenue
  ↓
Margin
```

## Economic Snapshots

Historical reports should be reproducible. If prices, allocations, or cost assumptions change, historical economic reports must not silently change without an explicit recalculation/versioning event.

## Consequences

### Positive

- Management can compare production and trading opportunities on economics rather than volume alone.
- The Rp500 million reference program can be measured from real unit economics.
- Capital allocation can be optimized across crop, fish, poultry, trading, and online business.
- Finance remains useful without requiring a complete general ledger in V0.1.

### Negative

- Requires disciplined attribution and allocation.
- Some overhead costs cannot be perfectly attributed.
- Financial reporting will require clear calculation definitions.

## Next Step

Define the open-core/commercial boundary and then produce the first canonical entity model and ERD for V0.1.
